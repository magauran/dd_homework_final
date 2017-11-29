//
//  FlickrAPI.h
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FlickrAPITopTagsDelegate <NSObject>

- (void)printTopTags:(NSArray *)tags;

@end

@interface FlickrAPI: NSObject

- (void)getTopTags:(id<FlickrAPITopTagsDelegate>) delegate;

@end