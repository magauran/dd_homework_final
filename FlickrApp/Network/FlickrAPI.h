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
@property(strong,nonatomic) NSArray * tags;

@end
