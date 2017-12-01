//
//  Tag.h
//  FlickrApp
//
//  Created by Алексей on 01.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tag : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *photo;

- (id) initWithTitle: (NSString *)title andPhoto: (UIImage *)photo;

@end
