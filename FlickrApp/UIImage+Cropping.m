//
//  UIImage+Cropping.m
//  FlickrApp
//
//  Created by Алексей on 03.12.2017.
//  Copyright © 2017 Алексей. All rights reserved.
//

#import "UIImage+Cropping.h"

@implementation UIImage (Cropping)


- (UIImage *)cropImageToSize:(CGSize)size {
    double refWidth = CGImageGetWidth(self.CGImage);
    double refHeight = CGImageGetHeight(self.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return cropped;
}


@end
