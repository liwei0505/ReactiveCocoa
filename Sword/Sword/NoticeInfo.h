//
//  NoticeInfo.h
//  mobip2p
//
//  Created by lw on 16/6/2.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoticeInfo : NSObject

@property (copy, nonatomic) NSString *content;  // 公告内容
@property (assign, nonatomic) int noticeId;     // 公告ID
@property (copy, nonatomic) NSString *datetime; // 创建时间
@property (copy, nonatomic) NSString *title;    // 公告标题
@property (copy, nonatomic) NSString *h5url;    // h5

@end
