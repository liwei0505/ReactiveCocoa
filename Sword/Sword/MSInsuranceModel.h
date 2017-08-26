//
//  MSInsuranceModel.h
//  Sword
//
//  Created by msj on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSInsuranceModel : NSObject
@property(nonatomic, copy, readonly) NSString *title;
@property(nonatomic, copy, readonly) NSString *icon;
@property(nonatomic, assign, readonly) PayType payType;
- (instancetype)initWithTitle:(NSString *)title withIcon:(NSString *)icon withShareType:(PayType)payType;
@end
