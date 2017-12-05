//
//  Tag.m
//  FlickrApp
//
//  Created by Алексей on 01.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "Tag.h"


@implementation Tag


- (id) initWithTitle: (NSString *)title andPhoto: (Photo *)photo {
    self = [super init];
    if (self) {
        self.title = title;
        self.photo = photo;
    }
    return self;
}


@end
