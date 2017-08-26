//
//  MSStoryboardLoader.h
//  Sword
//
//  Created by haorenjie on 16/5/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSStoryboardLoader : NSObject

+ (__kindof UIViewController *)loadViewController:(NSString *)name withIdentifier:(NSString *)indentifier;
+ (nullable __kindof UIViewController *)loadInitialViewController:(NSString *)storyboardName;

@end

NS_ASSUME_NONNULL_END
