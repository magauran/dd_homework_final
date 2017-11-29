//
//  TopTagsViewController.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "TopTagsViewController.h"


@interface TopTagsViewController()

@property (nonatomic, strong) NSArray *topTags;
@property (weak, nonatomic) IBOutlet UITableView *tagsTable;

@end


@implementation TopTagsViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    FlickrAPI *flickr = [[FlickrAPI alloc] init];
    [flickr getTopTags:self];
}
g

- (void)setTopTags:(NSArray *)tags {
    NSLog(@"%@", tags);
    _topTags = tags;
    [_tagsTable reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag"];
    cell.tagTitle.text = [[_topTags objectAtIndex:indexPath.row] valueForKeyPath:@"_content"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topTags.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


@end
