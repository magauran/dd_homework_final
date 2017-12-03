//
//  PhotoViewController.m
//  FlickrApp
//
//  Created by Алексей on 03.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photo;

@end


@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photo.image = self.lowQualityImage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateImage];
    });
}


- (void)updateImage {
    NSData *imageData = [NSData dataWithContentsOfURL:self.photoUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photo.image = image;
    });
}

@end
