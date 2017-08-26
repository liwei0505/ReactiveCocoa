//
//  IMSOperatingService.h
//  Sword
//
//  Created by haorenjie on 2017/2/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"
#import "UpdateInfo.h"
#import "FeedbackInfo.h"

@protocol IMSOperatingService <NSObject>

- (RACSignal *)querySystemConfig;
- (RACSignal *)queryInviteCode:(ShareType)shareType;
- (RACSignal *)queryVerifyCodeByPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim;

- (RACSignal *)queryBannerList;
- (BOOL)isShouldQueryBannerList;

- (RACSignal *)queryGoodsListByType:(ListRequestType)requestType;
- (BOOL)hasMoreGoodsList;
- (RACSignal *)exchangeByGoodsId:(NSNumber *)goodsId;

- (RACSignal *)queryAbout;
- (RACSignal *)queryHelpListByType:(ListRequestType)requestType;
- (RACSignal *)queryNoticeListByType:(ListRequestType)requestType;
- (RACSignal *)queryLatestNoticeId;

- (RACSignal *)queryUnreadMessageCount;
- (RACSignal *)queryMessageListByType:(ListRequestType)requestType;
- (RACSignal *)readMessageWithId:(NSNumber *)messageId;
- (RACSignal *)deleteMessageWithId:(NSNumber *)messageId;

- (RACSignal *)checkUpdate;
- (UpdateInfo *)getUpdateInfo;

- (RACSignal *)queryRiskAssessment;
- (RACSignal *)commitRiskAssessmentWithAnswers:(NSArray *)answers;
- (RACSignal *)queryRiskInfoByType:(RiskType)riskType;

- (RACSignal *)queryNewUrlWithOldUrl:(NSString *)url;
- (RACSignal *)feedback:(FeedbackInfo *)feedbackInfo;

@end
