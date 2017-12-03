//
//  TagTableViewCell.h
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tagTitle;
@property (weak, nonatomic) IBOutlet UIImageView *tagImage;

@end
