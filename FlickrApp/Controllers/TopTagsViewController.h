//
//  TopTagsViewController.h
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagTableViewCell.h"
#import "FlickrAPI.h"

@interface TopTagsViewController : UIViewController <FlickrAPITopTagsDelegate, UITableViewDelegate, UITableViewDataSource>



@end
