//
//  MSInviteView.h
//  Sword
//
//  Created by msj on 2017/3/28.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInviteView : UIView
@property (copy, nonatomic) void(^selectedShareType)(NSString *title);
-(void)setShareUrl:(NSString *)shareUrl shareTitle:(NSString *)title shareContent:(NSString *)content shareIcon:(NSString *)iconUrl shareId:(NSString *)shareId;
@end
