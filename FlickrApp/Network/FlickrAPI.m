//
//  FlickrAPI.m
//  FlickrApp
//
//  Created by Алексей on 29.11.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//


#import "FlickrAPI.h"

@implementation FlickrAPI

static NSString *flickrBaseUrl = @"https://api.flickr.com/services/rest";

static NSString *flickrAPIKey = @"7147eaf2e358e66ab204b2978c54e6da";


- (NSURL *)flickrURLForMethod:(NSString *)method withParameters:(NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:flickrBaseUrl];
    NSMutableArray *queryItems = [[NSMutableArray alloc] init];
    NSDictionary *baseParameters = @{ @"method" : method,
                                  @"format" : @"json",
                                  @"nojsoncallback" : @"1",
                                  @"api_key" : flickrAPIKey
                                  };
    
    [baseParameters enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        NSURLQueryItem * item = [[NSURLQueryItem alloc] initWithName:key value:obj];
        [queryItems addObject:item];
    }];
    
    if (parameters) {
        [parameters enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSURLQueryItem * item = [[NSURLQueryItem alloc] initWithName:key value:obj];
            [queryItems addObject:item];
        }];
    }
    
    components.queryItems = queryItems;
    return components.URL;
}


- (void)getTopTags:(id <FlickrAPITopTagsDelegate>)delegate {
    NSMutableArray * __block outTags;
    NSDictionary *additionalParameters = @{@"period" : @"day",
                                           @"count" : @"5"
                                           };
    NSURL * url = [self flickrURLForMethod:@"flickr.tags.getHotList"
                            withParameters:additionalParameters];
    
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask * task = [session downloadTaskWithURL:url
                                                 completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                     if (!error) {
                                                         NSData * jsonResults = [NSData dataWithContentsOfURL:url];
                                                         NSDictionary * results = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                                                  options:0 error:NULL];
                                                         NSArray *topTags = [[results objectForKey:@"hottags"] objectForKey:@"tag"];
                                                         outTags = [[NSMutableArray alloc] init];
                                                         
                                                         dispatch_queue_t queue = dispatch_queue_create("photos", 0);
                                                         
                                                         for (id tag in topTags) {
                                                             
                                                             dispatch_async(queue, ^{
                                                                 dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                                                                 
                                                                 NSString *title = [tag valueForKeyPath:@"_content"];
                                                                 
                                                                 [self getPhotoByTag:title indexNumber:0 completion:^(Photo *image) {
                                                                     Tag *tag = [[Tag alloc] initWithTitle:title andPhoto:image.source];
                                                                     [outTags addObject:tag];
                                                                     dispatch_semaphore_signal(sema);
                                                                     
                                                                 }];
                                                                 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                                                                 NSLog(@"Got one photo.");
                                                             });
                                                             
                                                         }
                                                         
                                                         dispatch_async(queue, ^{
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [delegate setTopTags:outTags];
                                                             });
                                                         });
                                                     } else {
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    [task resume];
}


- (void)getPhotoByTag:(NSString *)tag indexNumber:(NSInteger)index completion:(void (^)(Photo *))completion {
    NSDictionary *additionalParameters = @{@"tags" : tag
                                           };
    NSURL * url = [self flickrURLForMethod:@"flickr.photos.search"
                            withParameters:additionalParameters];

    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask * task = [session downloadTaskWithURL:url
                                                 completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                     if (!error) {
                                                         NSData * jsonResults = [NSData dataWithContentsOfURL:url];
                                                         NSDictionary * results = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                                                  options:0 error:NULL];
                                                         NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
                                                         
                                                         Photo *photo = [[Photo alloc] initWithPhotoDictionary:photos[index]];
                                                         
                                                         
                                                         completion(photo);
                                                         
                                                     } else {
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    [task resume];
}


@end
