//
//  ViewController.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FlickrAPI *flickr = [[FlickrAPI alloc] init];
    [flickr getTopTags:self];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)printTopTags:(NSArray *)tags {
    NSLog(@"%@", tags);
}


@end
