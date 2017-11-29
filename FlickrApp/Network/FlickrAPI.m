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

    NSDictionary *additionalParameters = @{@"period" : @"week",
                                           @"count" : @"20"
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
                                                         NSArray * topTags = [[results objectForKey:@"hottags"] objectForKey:@"tag"];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
//                                                             NSLog(@"%@", topTags);
                                                             [delegate printTopTags:topTags];
                                                         });
                                                     } else {
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    [task resume];
}


@end
