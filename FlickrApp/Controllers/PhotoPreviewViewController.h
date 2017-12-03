//
//  PhotoPreviewViewController.h
//  FlickrApp
//
//  Created by Алексей on 01.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionViewCell.h"
#import "PhotoViewController.h"
#import "FlickrAPI.h"

@interface PhotoPreviewViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSString *selectedTag;

@end
