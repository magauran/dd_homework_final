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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) FlickrAPI *flickr;

@end


@implementation TopTagsViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    [_tagsTable setHidden:true];
    _flickr = [[FlickrAPI alloc] init];
    [_flickr getTopTags:self];
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
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
        self.tagsTable.contentOffset = CGPointMake(0, -self.refreshControl.bounds.size.height);
        [self.refreshControl beginRefreshing];
    }
}


- (void)updateTable {
    self.flickr = [[FlickrAPI alloc] init];
    [self.flickr getTopTags:self];
}


- (void)setTopTags:(NSArray *)tags {
    _topTags = tags;
    [_tagsTable reloadData];
    [_tagsTable setHidden:false];
    [self.activityIndicator stopAnimating];
    [self.refreshControl endRefreshing];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag"];
    Tag *tag = [_topTags objectAtIndex:indexPath.row];
    cell.tagTitle.text = tag.title;
    CGFloat width = tag.photo.size.width;
    CGFloat height = width * 150 / self.view.bounds.size.width;
    cell.tagImage.image = [tag.photo cropImageToSize:CGSizeMake(width, height)] ;
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


@end
