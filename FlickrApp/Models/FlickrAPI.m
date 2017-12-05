//
//  FlickrAPI.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//


#import "FlickrAPI.h"


@implementation FlickrAPI


static NSString *const kFlickrBaseUrl = @"https://api.flickr.com/services/rest";
static NSString *const kFlickrAPIKey = @"7147eaf2e358e66ab204b2978c54e6da";


- (NSURL *)flickrURLForMethod:(NSString *)method withParameters:(NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:kFlickrBaseUrl];
    NSMutableArray *queryItems = [[NSMutableArray alloc] init];
    NSDictionary *baseParameters = @{@"method" : method,
                                     @"format" : @"json",
                                     @"nojsoncallback" : @"1",
                                     @"api_key" : kFlickrAPIKey
                                    };
    
    [baseParameters enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:obj];
        [queryItems addObject:item];
    }];
    
    if (parameters) {
        [parameters enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:obj];
            [queryItems addObject:item];
        }];
    }
    
    components.queryItems = queryItems;
    return components.URL;
}


- (void)getTopTagsWithCount:(NSInteger)count completion:(void (^)(NSArray *))completion {
  
    NSDictionary *additionalParameters = @{@"period" : @"day",
                                           @"count" : @"5"
                                           };
    NSURL *url = [self flickrURLForMethod:@"flickr.tags.getHotList"
                            withParameters:additionalParameters];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url
                                     completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                     if (!error) {
                                                         NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:0 error:NULL];
                                                         
                                                         if ([[results objectForKey:@"stat"] isEqual:@"fail"]) {
                                                             completion(nil);
                                                         }
                                                         
                                                         NSArray *tags = [[results objectForKey:@"hottags"] objectForKey:@"tag"];
                                                         NSMutableArray *returnTags = [[NSMutableArray alloc] init];
                                                        
                                                         for (NSInteger i = 0; i < count & i < tags.count; ++i) {
                                                             NSString *title = [tags[i] valueForKeyPath:@"_content"];
                                                             
                                                             Tag *tag = [[Tag alloc] initWithTitle:title andPhoto:nil];
                                                             [returnTags addObject:tag];
                                                         }
                                                         if (returnTags.count > 0) {
                                                             completion(returnTags);
                                                         } else {
                                                             completion(nil);
                                                         }
                                                         
                                                     } else {
                                                         NSLog(@"ERROR: %ld", error.code);
                                                         completion(nil);
                                                     }
                                                 }];
    [task resume];
}


- (void)getPhotoByTag:(NSString *)tag indexNumber:(NSInteger)index sizeLiteral:(NSString *)size completion:(void (^)(Photo *))completion {
    if (!tag) {
        completion(nil);
        return;
    }
    NSDictionary *additionalParameters = @{@"tags" : tag};
    NSURL *url = [self flickrURLForMethod:@"flickr.photos.search"
                            withParameters:additionalParameters];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url
                                     completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                         if (!error) {
                                             NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0 error:NULL];
                                                         
                                                         if ([[results objectForKey:@"stat"] isEqual:@"fail"]) {
                                                             completion(nil);
                                                         }
                                                         
                                                         NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
                                                         if (photos.count > index) {
                                                             Photo *photo = [[Photo alloc] initWithPhotoDictionary:photos[index] andSize:size];
                                                             completion(photo);
                                                         } else {
                                                             completion(nil);
                                                         }
                                                         
                                                     } else {
                                                         NSLog(@"ERROR: %ld", error.code);
                                                         completion(nil);
                                                     }
                                                 }];
    [task resume];
}


- (void)getPhotosByTag:(NSString *)tag count:(NSInteger)count sizeLiteral:(NSString *)size completion:(void (^)(NSArray *))completion {
    if (!tag) {
        completion(nil);
        return;
    }
    NSDictionary *additionalParameters = @{@"tags" : tag};
    NSURL *url = [self flickrURLForMethod:@"flickr.photos.search"
                            withParameters:additionalParameters];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url
                                     completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                         if (!error) {
                                             NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:NULL];
                                             if ([[results objectForKey:@"stat"] isEqual:@"fail"]) {
                                                 completion(nil);
                                             }
                                                         
                                             NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
                                                         
                                             NSMutableArray *returnPhotos = [[NSMutableArray alloc] init];
                                                for (NSInteger i = 0; i < count & i < photos.count; ++i) {
                                                    Photo *photo = [[Photo alloc] initWithPhotoDictionary:photos[i] andSize:size];
                                                    [returnPhotos addObject:photo];
                                                }
                                                if (returnPhotos.count > 0) {
                                                    completion(returnPhotos);
                                                } else {
                                                    completion(nil);
                                                }
                                             
                                         } else {
                                             NSLog(@"ERROR: %ld", error.code);
                                             completion(nil);
                                         }
                                     }];
    [task resume];
}


@end
