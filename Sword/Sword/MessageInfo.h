//
//  MSMessageInfo.h
//  mobip2p
//
//  Created by lee on 16/5/19.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageInfo : NSObject

@property (copy, nonatomic) NSString *content;
@property (assign, nonatomic) int messageId;
@property (assign, nonatomic) int status;          // 0: 未读 1: 已读
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *sendDate;

@end


