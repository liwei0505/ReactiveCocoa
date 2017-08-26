//
//  MSConfig.h
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATUS_BAR_HEIGHT 20
#define NAVIGATION_BAR_HEIGHT 44
#define TAB_BAR_HEIGHT 49
#define ANIMATION_DURATION 0.25
#define MS_PAGE_SIZE  12
#define SCREEN_WIDTH_4S 320
#define PROTOCOL_AUTO_SELECTED 1
#define PATTERNLOCK_PASSWORD_LENGTH 4
#define PATTERNLOCK_PASSWORD_ERROR_COUNT 5


#define TYPE @"type"
#define LIST @"list"
#define TOTALCOUNT @"totalCount"
#define LOANID  @"loanId"
#define CONTENT @"content"
#define STATUS  @"status"


#define scaleX   ([UIScreen mainScreen].bounds.size.width / 320.0)
#define scaleY   ([UIScreen mainScreen].bounds.size.height / 568.0 < 1.0 ? 1.0 : [UIScreen mainScreen].bounds.size.height / 568.0)


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MS_COLOR_MAIN UIColorFromRGB(0x333092)

//统计
//#define PRODUCT_SERVER_URL @"https://transactor.minshengjf.com:6109/transactor/mjsfax_app_ios/mtrack" //数据接收
//#define PRODUCT_CONFIGURE_URL @"https://transactor.minshengjf.com:6109/transactor/mjsfax_app_ios/app_config"   //配置分发url
//
//#define PREREALSE_SERVER_URL @"https://mjsytc.minshengjf.com:6507/transactor/mjsfax_app_ios/mtrack"
//#define PREREALSE_CONFIGURE_URL @"https://mjsytc.minshengjf.com:6507/transactor/mjsfax_app_ios/app_config"
//
//#define TEST_SERVER_URL @"http://10.0.110.46:8080/transactor/mjsfax_app_ios/mtrack"
//#define TEST_CONFIGURE_URL @"http://10.0.110.46:8080/transactor/mjsfax_app_ios/app_config"


//个推生产参数
#define kGtAppId           @"iVSiW5jebb8h0nRMp2Tjn3"
#define kGtAppKey          @"RyEQPpvnglAccmoo6REOE8"
#define kGtAppSecret       @"T7Co9KTmGyAneCNzD6yUo1"
//个推测试参数
#define kGtTestAppId           @"5cRdXWRSD065HTOKnODx4A"
#define kGtTestAppKey          @"GBEWBxanEp7lQ95cQj3udA"
#define kGtTestAppSecret       @"MhWpLbtczx5yqNbc8ej6L6"
