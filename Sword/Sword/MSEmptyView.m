//
//  MSEmptyView.m
//  Sword
//
//  Created by haorenjie on 16/6/8.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSEmptyView.h"

@implementation MSEmptyView

+ (MSEmptyView *)instance
{
    UINib *nibFile = [UINib nibWithNibName:@"EmptyView" bundle:nil];
    return [[nibFile instantiateWithOwner:nil options:nil] lastObject];
}

@end
