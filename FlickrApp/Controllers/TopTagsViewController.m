//
//  TopTagsViewController.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "TopTagsViewController.h"


@interface TopTagsViewController()

@property (strong, nonatomic) NSArray *topTags;
@property (weak, nonatomic) IBOutlet UITableView *tagsTable;

@end


@implementation TopTagsViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    FlickrAPI *flickr = [[FlickrAPI alloc] init];
    [flickr getTopTags:self];
}


- (void)setTopTags:(NSArray *)tags {
    _topTags = tags;
    [_tagsTable reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag"];
    Tag *tag = [_topTags objectAtIndex:indexPath.row];
    cell.tagTitle.text = tag.title;
    CGFloat width = tag.photo.size.width;
    CGFloat height = width * 150 / self.view.bounds.size.width;
    cell.tagImage.image = [self imageByCroppingImage:tag.photo toSize:CGSizeMake(width, height)] ;
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topTags.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tag *selectedTag = [_topTags objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"TagSegue" sender:selectedTag.title];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"TagSegue"]) {
        PhotoPreviewViewController *controller = (PhotoPreviewViewController *)segue.destinationViewController;
        controller.selectedTag = sender;
    }
}


- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size {
    
    
    
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return cropped;
}


@end
