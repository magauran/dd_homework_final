//
//  Photo.m
//  FlickrApp
//
//  Created by Алексей on 01.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "Photo.h"


@implementation Photo


- (instancetype)initWithPhotoDictionary:(NSDictionary *)dictionary andSize:(NSString *)size {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.photoId = dictionary[@"id"];
    self.secret = dictionary[@"secret"];
    self.server = dictionary[@"server"];
    self.farm = dictionary[@"farm"];
    self.title = dictionary[@"title"];
    
    NSURL *searchURL = [self flickrPhotoURLForFlickrPhoto:self size:size];
    self.largeSizePhotoUrl = [self flickrPhotoURLForFlickrPhoto:self size:@"_b"];
    NSData *imageData = [NSData dataWithContentsOfURL:searchURL];
    UIImage *image = [UIImage imageWithData:imageData];
    self.source = image;
    
    return self;
}

- (NSURL *)flickrPhotoURLForFlickrPhoto:(Photo *)flickrPhoto
                                   size:(NSString *)size {
    
    NSString *urlString = [self flickrPhotoURLStringForFlickrPhoto:flickrPhoto
                                                              size:size];
    return [NSURL URLWithString:urlString];
}

- (NSString *)flickrPhotoURLStringForFlickrPhoto:(Photo *)flickrPhoto
                                            size:(NSString *)size {
    if(!size) {
        size = @"";
    }
    return [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@%@.jpg",
            flickrPhoto.farm, flickrPhoto.server,
            flickrPhoto.photoId, flickrPhoto.secret, size];
}


@end
