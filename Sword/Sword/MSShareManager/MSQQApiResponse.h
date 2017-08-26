//
//  MSQQApiResponse.h
//  Sword
//
//  Created by msj on 16/10/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "MSToast.h"

@interface MSQQApiResponse : NSObject<QQApiInterfaceDelegate, TencentSessionDelegate>
@property(nonatomic,strong) TencentOAuth *tencentOAuth;
@end
