//
//  MSInsuranceModel.m
//  Sword
//
//  Created by msj on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceModel.h"

@interface MSInsuranceModel ()
@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, copy, readwrite) NSString *icon;
@property(nonatomic, assign, readwrite) PayType payType;
@end

@implementation MSInsuranceModel
- (instancetype)initWithTitle:(NSString *)title withIcon:(NSString *)icon withShareType:(PayType)payType {
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = icon;
        self.payType = payType;
    }
    return self;
}
@end
