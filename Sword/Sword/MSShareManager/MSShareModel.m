//
//  MSShareModel.m
//  Sword
//
//  Created by msj on 16/10/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSShareModel.h"

@interface MSShareModel ()
@property(nonatomic,copy, readwrite) NSString *title;
@property(nonatomic,copy, readwrite) NSString *icon;
@property(nonatomic,assign, readwrite) MSShareType shareType;
@end

@implementation MSShareModel
-(instancetype)initWithTitle:(NSString *)title withIcon:(NSString *)icon withShareType:(MSShareType)shareType
{
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = icon;
        self.shareType = shareType;
    }
    return self;
}

@end
