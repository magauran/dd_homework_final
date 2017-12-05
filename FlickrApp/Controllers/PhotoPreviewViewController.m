//
//  PhotoPreviewViewController.m
//  FlickrApp
//
//  Created by Алексей on 01.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "PhotoPreviewViewController.h"


@interface PhotoPreviewViewController () {
 @private
    __weak IBOutlet UICollectionView *_collectionView;
    
     FlickrAPI *_flickr;
     NSInteger _photosInRow;
     NSMutableArray *__block _photos;
     UIRefreshControl *_refreshControl;
}
@end


@implementation PhotoPreviewViewController


static const NSInteger kPhotosCount = 15;


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _collectionView.alwaysBounceVertical = YES;
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = _collectionView.backgroundColor;
    _refreshControl.tintColor = [UIColor blackColor];
    [_refreshControl addTarget:self
                            action:@selector(updateCollection)
                  forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    [_refreshControl beginRefreshing];
    
    [self updateCollection];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        _collectionView.contentOffset = CGPointMake(0, -CGRectGetHeight(_refreshControl.frame));
        [_refreshControl beginRefreshing];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


#pragma mark - UICollectionViewDataSource

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    if (_photos.count > index) {
        Photo *previewPhoto = [_photos objectAtIndex:index];
        
        if (previewPhoto.photoUrl) {
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:previewPhoto.photoUrl completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            PhotoCollectionViewCell *updateCell = (id)[collectionView cellForItemAtIndexPath:indexPath];
                            if (updateCell) {
                                updateCell.image.image = image;
                                previewPhoto.source = image;
                                _photos[index] = previewPhoto;
                            }
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
    return _photos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger kPhotoSpacing = 10;
    CGFloat cellSide = (CGRectGetWidth(collectionView.frame) - kPhotoSpacing * (_photosInRow - 1)) / _photosInRow;
    return CGSizeMake(cellSide, cellSide);
}


#pragma mark - UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    Photo *photo = [_photos objectAtIndex:index];
    if (photo) {
        [self performSegueWithIdentifier:@"ShowPhotoSegue" sender:photo];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"ShowPhotoSegue"]) {
        PhotoViewController *controller = (PhotoViewController *)segue.destinationViewController;
        NSURL *url = [(Photo*)sender largeSizePhotoUrl];
        UIImage *image = [(Photo *)sender source];
        controller.photoUrl = url;
        controller.lowQualityImage = image;
    }
}


#pragma mark - Orientation

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
    [_collectionView reloadData];
}


#pragma mark - Other

- (void)updateCollection {
    _flickr = [[FlickrAPI alloc] init];
    NSMutableArray *__block photo = [[NSMutableArray alloc] initWithCapacity:kPhotosCount];
    dispatch_queue_t queue = dispatch_queue_create("photos", 0);
    dispatch_async(queue, ^{
        [_flickr getPhotosByTag:self.selectedTag count:kPhotosCount sizeLiteral:@"_t" completion:^(NSArray *returnPhotos) {
            if (returnPhotos) {
                [photo addObjectsFromArray:returnPhotos];
            }
            _photos = photo;
            for (Photo *i in _photos) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_collectionView reloadData];
                    if (i == _photos.lastObject) {
                        [_refreshControl endRefreshing];
                    }
                });
            }
        }];
    });
}


@end
