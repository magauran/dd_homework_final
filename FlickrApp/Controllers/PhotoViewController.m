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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *container;

@end


@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat imageViewAspectRatio = self.container.frame.size.width / self.container.frame.size.height;
    CGFloat photoAspectRatio = self.lowQualityImage.size.width / self.lowQualityImage.size.height;
    CGFloat width, height;
    
    if (photoAspectRatio > imageViewAspectRatio) {
        width = self.container.frame.size.width;
        height = width / photoAspectRatio;
    } else {
        height = self.photo.frame.size.height;
        width = height * photoAspectRatio;
    }
    
    self.photoWidthConstraint.constant = width;
    self.photoHeightConstraint.constant = height;
    [self.view layoutIfNeeded];
    
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
