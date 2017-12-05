//
//  TopTagsViewController.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "TopTagsViewController.h"


@interface TopTagsViewController() {
 @private
    __weak IBOutlet UITableView *_tagsTable;
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    
    FlickrAPI *_flickr;
    NSMutableArray *_topTags;
    UIRefreshControl *_refreshControl;
}
@end


@implementation TopTagsViewController 


static const NSInteger kTagsCount = 10;


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tagsTable setHidden:true];
    
    _flickr = [[FlickrAPI alloc] init];
    [self updateTable];
    [_activityIndicator startAnimating];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = _tagsTable.backgroundColor;
    _refreshControl.tintColor = [UIColor blackColor];
    [_refreshControl addTarget:self
                            action:@selector(updateTable)
                  forControlEvents:UIControlEventValueChanged];
    [_tagsTable addSubview:_refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tagsTable setContentOffset:CGPointMake(0, -CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame)) animated:false];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        _tagsTable.contentOffset = CGPointMake(0, -CGRectGetHeight(_refreshControl.frame));
        [_refreshControl beginRefreshing];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag"];
    Tag *tag = [_topTags objectAtIndex:indexPath.row];
    cell.tagTitle.text = tag.title;
    cell.backgroundColor = UIColor.blackColor;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    if (tag.photo.photoUrl) {
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:tag.photo.photoUrl completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        TagTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            updateCell.tagImage.image = image;
                        }
                    });
                }
            }
        }];
        [task resume];
    }
    
    cell.tagImage.image = tag.photo.source;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topTags.count;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tag *selectedTag = [_topTags objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"TagSegue" sender:selectedTag.title];
}


#pragma mark - Orientation

- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    [_tagsTable reloadData];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"TagSegue"]) {
        PhotoPreviewViewController *controller = (PhotoPreviewViewController *)segue.destinationViewController;
        controller.selectedTag = sender;
    }
}


#pragma mark - Other

- (void)updateTable {
    _flickr = [[FlickrAPI alloc] init];
    NSMutableArray *__block tags = [[NSMutableArray alloc] initWithCapacity:kTagsCount];
    dispatch_queue_t queue = dispatch_queue_create("tags", 0);
    dispatch_async(queue, ^{
        [_flickr getTopTagsWithCount:kTagsCount completion:^(NSArray *returnTags) {
            if (returnTags) {
                [tags addObjectsFromArray:returnTags];
            }
            _topTags = tags;
            for (NSInteger i = 0; i < tags.count; ++i) {
                Tag *tag = _topTags[i];
                [_flickr getPhotoByTag:tag.title indexNumber:0 sizeLiteral:@"" completion:^(Photo *photo) {
                    tag.photo = photo;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tagsTable reloadData];
                        [_tagsTable setHidden:false];
                        if (tag == _topTags.lastObject) {
                            [_activityIndicator stopAnimating];
                            [_refreshControl endRefreshing];
                        }
                    });
                }];
            }
        }];
    });
}


@end
