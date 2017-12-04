//
//  SearchViewController.h
//  FlickrApp
//
//  Created by Алексей on 04.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrAPI.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoViewController.h"

@interface SearchViewController : UIViewController <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@end
