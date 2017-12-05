//
//  FlickrAPI.h
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"
#import "Photo.h"

@protocol FlickrAPITopTagsDelegate <NSObject>

- (void)setTopTags:(NSArray *)tags;

@end

@interface FlickrAPI: NSObject

- (void)getTopTags:(id<FlickrAPITopTagsDelegate>) delegate;
- (void)getPhotoByTag:(NSString *)tag indexNumber:(NSInteger)index sizeLiteral:(NSString *)size completion:(void (^)(Photo *))completion;
- (void)getPhotosByTag:(NSString *)tag count:(NSInteger)count sizeLiteral:(NSString *)size completion:(void (^)(NSArray *))completion;
@property(strong,nonatomic) NSArray * tags;

@end
