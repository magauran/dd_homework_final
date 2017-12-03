//
//  PhotoViewController.h
//  FlickrApp
//
//  Created by Алексей on 03.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

@property (strong, nonatomic) NSURL *photoUrl;
@property (strong, nonatomic) UIImage *lowQualityImage;

@end
