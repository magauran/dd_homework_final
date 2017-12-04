//
//  SearchViewController.m
//  FlickrApp
//
//  Created by Алексей on 04.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *__block photos;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    [searchBar resignFirstResponder];
    [self searchPhotosByTag:searchText];
}


- (void)searchPhotosByTag:(NSString *)tag {
    FlickrAPI *flickr = [[FlickrAPI alloc] init];
    NSMutableArray *__block photo = [[NSMutableArray alloc] initWithCapacity:9];
    
    
    
    dispatch_queue_t queue = dispatch_queue_create("photos", 0);
    for (int i = 0; i < 9; ++i) {
        dispatch_async(queue, ^{
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            [flickr getPhotoByTag:tag indexNumber:i sizeLiteral:@"_t" completion:^(Photo *image) {
                [photo addObject:image];
                dispatch_semaphore_signal(sema);
                _photos = photo;
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        });
        
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
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
