//
//  SearchViewController.m
//  FlickrApp
//
//  Created by Алексей on 04.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController () {
@private
    NSInteger _count;
    FlickrAPI *_flickr;
    NSString *_searchTag;
    NSInteger _photosInRow;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *__block photos;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 15;
    _searchTag = @"";
    self.collectionView.alwaysBounceVertical = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = self.collectionView.backgroundColor;
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(searchPhotos)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
        self.collectionView.contentOffset = CGPointMake(0, -self.refreshControl.bounds.size.height);
        [self.refreshControl beginRefreshing];
    }
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}


- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            _photosInRow = 3;
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            _photosInRow = 5;
        }
            break;
        case UIInterfaceOrientationUnknown: break;
    }
    [self.collectionView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    [searchBar resignFirstResponder];
    
    self.collectionView.contentOffset = CGPointMake(0, -60);
    [self.refreshControl beginRefreshing];
    
    _searchTag = searchText;
    [self searchPhotos];
}


- (void)searchPhotos {
    if ([_searchTag  isEqual: @""]) {
        [_photos removeAllObjects];
        self.searchIcon.image = [UIImage imageNamed:@"search-icon"];
        [self.collectionView reloadData];
        [self.searchIcon setHidden:false];
        [self.refreshControl endRefreshing];
    } else {
        [self.searchIcon setHidden:true];
        [self updateCollection];
    }
}


- (void)updateCollection {
    _flickr = [[FlickrAPI alloc] init];
    NSMutableArray *__block photo = [[NSMutableArray alloc] initWithCapacity:_count];
    dispatch_queue_t queue = dispatch_queue_create("photos", 0);
    dispatch_async(queue, ^{
        [_flickr getPhotosByTag:_searchTag count:_count sizeLiteral:@"_t" completion:^(NSArray *retPhotos) {
            if (retPhotos) {
                [photo addObjectsFromArray:retPhotos];
            }
            self.photos = photo;
            for (Photo *i in self.photos) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_collectionView reloadData];
                    if (i == self.photos.lastObject) {
                        [self.refreshControl endRefreshing];
                    }
                    
                });
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (self.photos.count == 0) {
                    self.searchIcon.image = [UIImage imageNamed:@"error-search-icon"];
                    [self.searchIcon setHidden:false];
                    [self.refreshControl endRefreshing];
                }
            });
        }];
    });
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    if (_photos.count > index) {
        Photo *previewPhoto = [_photos objectAtIndex:index];
   
        if (previewPhoto.photoUrl) {
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:previewPhoto.photoUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            PhotoCollectionViewCell *updateCell = (id)[collectionView cellForItemAtIndexPath:indexPath];
                            if (updateCell)
                                updateCell.image.image = image;
                        });
                    }
                }
            }];
            [task resume];
        }
        
        
    } else {
        cell.image.image = nil;
    }
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellSide = (collectionView.frame.size.width - 10 * (_photosInRow - 1)) / _photosInRow;
    return CGSizeMake(cellSide, cellSide);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    Photo *photo = [_photos objectAtIndex:index];
    if (photo) {
        [self performSegueWithIdentifier:@"ShowPhotoFoundSegue" sender:photo];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"ShowPhotoFoundSegue"]) {
        PhotoViewController *controller = (PhotoViewController *)segue.destinationViewController;
        NSURL *url = [(Photo*)sender largeSizePhotoUrl];
        UIImage *image = [(Photo *)sender source];
        controller.photoUrl = url;
        controller.lowQualityImage = image;
    }
}


@end
