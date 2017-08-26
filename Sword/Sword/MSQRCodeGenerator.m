//
//  MSQRCodeGenerator.m
//  showTime
//
//  Created by msj on 2017/3/17.
//  Copyright © 2017年 msj. All rights reserved.
//

#import "MSQRCodeGenerator.h"

@implementation MSQRCodeGenerator
+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message {
    return [self ms_creatQRCodeWithMessage:message size:500];
}

+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message  size:(CGFloat)size {
    return [self ms_creatQRCodeWithMessage:message size:size logo:nil];
}

+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message  logo:(UIImage *)logo {
    return [self ms_creatQRCodeWithMessage:message size:500 logo:logo];
}

+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message  size:(CGFloat)size logo:(UIImage *)logo {
    
    if (![message isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    if (message == nil || message.length == 0) {
        return nil;
    }
    
    if (size <= 0) {
        return nil;
    }
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:[message dataUsingEncoding:NSUTF8StringEncoding] forKeyPath:@"inputMessage"];
    CIImage *ciImage = filter.outputImage;
    
    CGRect extentRect = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extentRect), size / CGRectGetHeight(extentRect));
    
    size_t width = CGRectGetWidth(extentRect) * scale;
    size_t height = CGRectGetHeight(extentRect) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(NULL, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);

    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extentRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extentRect, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGColorSpaceRelease(cs);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    UIImage *resultImage;
    if (logo && [logo isKindOfClass:[UIImage class]]) {
        UIImage *logoImage = [self cutLogo:logo];
        UIImage *qrCodeImage = [UIImage imageWithCGImage:scaledImage];
        
        CGRect bigRect = CGRectMake(0, 0, CGImageGetWidth(qrCodeImage.CGImage), CGImageGetHeight(qrCodeImage.CGImage));
        CGRect smallRect = CGRectMake(bigRect.size.width * 0.7 * 0.5, bigRect.size.height * 0.7 * 0.5, bigRect.size.width * 0.3, bigRect.size.height * 0.3);
        
        UIGraphicsBeginImageContextWithOptions(bigRect.size, NO, 0);
        [qrCodeImage drawInRect:bigRect];
        [logoImage drawInRect:smallRect];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else {
        resultImage = [UIImage imageWithCGImage:scaledImage];
    }
    CGImageRelease(scaledImage);
    return resultImage;
}

#pragma mark - Private
+ (UIImage *)cutLogo:(UIImage *)logo {
    CGRect frame = CGRectMake(0, 0, logo.size.width, logo.size.height);
    UIGraphicsBeginImageContextWithOptions(logo.size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:10];
    [path addClip];
    [logo drawInRect:frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
