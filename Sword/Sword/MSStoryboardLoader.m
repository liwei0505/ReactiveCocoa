//
//  MSStoryboardLoader.m
//  Sword
//
//  Created by haorenjie on 16/5/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSStoryboardLoader.h"

@implementation MSStoryboardLoader

+ (UIViewController *)loadViewController:(NSString *)name withIdentifier:(NSString *)indentifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:indentifier];
}

+ (UIViewController *)loadInitialViewController:(NSString *)storyboardName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return [storyboard instantiateInitialViewController];
}

@end
