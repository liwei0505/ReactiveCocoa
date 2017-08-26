//
//  FeedbackInfo.h
//  Sword
//
//  Created by haorenjie on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

@interface FeedbackInfo : NSObject

@property (copy, nonatomic) NSString *suggestion;  // 反馈意见
@property (copy, nonatomic) NSString *contactInfo; // 联系方式
@property (copy, nonatomic) NSString *attachment;  // 上传的文件/文件夹路径

@end
