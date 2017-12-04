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
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *__block photos;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 9;
    self.collectionView.alwaysBounceVertical = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = self.collectionView.backgroundColor;
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateCollection)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    [searchBar resignFirstResponder];
    [self.refreshControl beginRefreshing]; // don't work
    [self searchPhotosByTag:searchText];
}


- (void)searchPhotosByTag:(NSString *)tag {
    _searchTag = tag;
    if ([tag  isEqual: @""]) {
        [_photos removeAllObjects];
        self.searchIcon.image = [UIImage imageNamed:@"search-icon"];
        [self.collectionView reloadData];
        [self.searchIcon setHidden:false];
    } else {
        [self.searchIcon setHidden:true];
        [self updateCollection];
    }

}


- (void)updateCollection {
    _flickr = [[FlickrAPI alloc] init];
    NSMutableArray *__block photo = [[NSMutableArray alloc] initWithCapacity:9];
    dispatch_queue_t queue = dispatch_queue_create("photos", 0);
    for (int i = 0; i < 9; ++i) {
        dispatch_async(queue, ^{
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            [_flickr getPhotoByTag:_searchTag indexNumber:i sizeLiteral:@"_t" completion:^(Photo *image) {
                if (image) {
                    [photo addObject:image];
                }
                self.photos = photo;
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        });
        
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                if (i == _count - 1) {
                    [_refreshControl endRefreshing];
                }
                if (self.photos.count == 0) {
                    self.searchIcon.image = [UIImage imageNamed:@"error-search-icon"];
                    [self.searchIcon setHidden:false];
                }
            });
        });
    }
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    if (_photos.count > index) {
        Photo *previewPhoto = [_photos objectAtIndex:index];
        CGFloat side = MIN(previewPhoto.source.size.width, previewPhoto.source.size.height);
        cell.image.image = [previewPhoto.source cropImageToSize:CGSizeMake(side, side)];
    } else {
        cell.image.image = nil;
    }
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellSide = (collectionView.frame.size.width - 20) / 3;
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
