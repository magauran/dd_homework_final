//
//  Photo.h
//  FlickrApp
//
//  Created by Алексей on 01.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Photo : NSObject


@property (strong, nonatomic) NSString *photoId;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *farm;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *source;
@property (strong, nonatomic) NSURL *photoUrl;
@property (strong, nonatomic) NSURL *largeSizePhotoUrl;

- (instancetype)initWithPhotoDictionary:(NSDictionary *)dictionary andSize:(NSString *)size;


@end
