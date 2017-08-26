//
//  MSInviteCode.h
//  mobip2p
//
//  Created by lw on 16/5/30.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InviteCode : NSObject

@property (copy, nonatomic) NSString *codeLink;     // 邀请码链接
@property (copy, nonatomic) NSString *desc;         // 描述信息
@property (copy, nonatomic) NSString *title;        // 分享标题
@property (copy, nonatomic) NSString *shareUrl;     // 分享图标


@end
