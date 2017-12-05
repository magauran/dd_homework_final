//
//  TopTagsViewController.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "TopTagsViewController.h"


@interface TopTagsViewController()

@property (strong, nonatomic) NSMutableArray *topTags;
@property (weak, nonatomic) IBOutlet UITableView *tagsTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) FlickrAPI *flickr;

@end


@implementation TopTagsViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    [_tagsTable setHidden:true];
    _flickr = [[FlickrAPI alloc] init];
    [self updateTable];
    [self.activityIndicator startAnimating];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = self.tagsTable.backgroundColor;
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateTable)
                  forControlEvents:UIControlEventValueChanged];
    [self.tagsTable addSubview:self.refreshControl];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
        self.tagsTable.contentOffset = CGPointMake(0, -self.refreshControl.bounds.size.height);
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
    [self.tagsTable reloadData];
}


- (void)updateTable {
    _flickr = [[FlickrAPI alloc] init];
    NSMutableArray *__block tags = [[NSMutableArray alloc] initWithCapacity:10];
    dispatch_queue_t queue = dispatch_queue_create("tags", 0);
    dispatch_async(queue, ^{
        [_flickr getTopTagsWithCount:10 completion:^(NSArray *retTags) {
            if (retTags) {
                [tags addObjectsFromArray:retTags];
            }
            self.topTags = tags;
            for (int i = 0; i < tags.count; ++i) {
                Tag *tag = self.topTags[i];
                [_flickr getPhotoByTag:tag.title indexNumber:0 sizeLiteral:@"" completion:^(Photo *photo) {
                    tag.photo = photo;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tagsTable reloadData];
                        [self.tagsTable setHidden:false];
                        if (tag == self.topTags.lastObject) {
                            [self.activityIndicator stopAnimating];
                            [self.refreshControl endRefreshing];
                        }
                    });
                }];
            }
        }];
    });
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag"];
    Tag *tag = [_topTags objectAtIndex:indexPath.row];
    cell.tagTitle.text = tag.title;
    cell.backgroundColor = UIColor.blackColor;
    
    if (tag.photo.photoUrl) {
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:tag.photo.photoUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        TagTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell)
                            updateCell.tagImage.image = image;
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
    return self.topTags.count;
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


@end
