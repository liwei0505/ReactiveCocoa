//
//  MSWBApiResponse.h
//  Sword
//
//  Created by msj on 16/10/19.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "MSToast.h"

@interface MSWBApiResponse : NSObject<WeiboSDKDelegate>
@property(nonatomic,strong) NSString *sinaAccessToken;
@property(nonatomic,strong) NSString *sinaUserId;
@end
