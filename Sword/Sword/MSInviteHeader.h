//
//  MSInviteHeader.h
//  Sword
//
//  Created by msj on 2017/7/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInviteHeader : UIView
@property (strong, nonatomic) InviteInfo *inviteInfo;
@property (copy, nonatomic) void (^block)(NSString *bannerLink);
@end
