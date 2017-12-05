//
//  PhotoViewController.m
//  FlickrApp
//
//  Created by Алексей on 03.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "PhotoViewController.h"


@interface PhotoViewController () {
 @private
    __weak IBOutlet UIImageView *_photo;
}
@end


@implementation PhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _photo.image = self.lowQualityImage;
    [self updateImage];
}


- (void)updateImage {
    if (self.photoUrl) {
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:self.photoUrl completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _photo.image = image;
                    });
                }
            }
        }];
        [task resume];
    }
}


@end
