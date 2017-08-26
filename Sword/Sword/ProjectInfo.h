//
//  ProjectInfo.h
//  Sword
//
//  Created by lee on 16/6/2.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ProjectType) {
    PROJECT_DIRECT_FINANCIAL = 0,  // 直融类
    PROJECT_CHANNEL = 1,           // 通道类
    PROJECT_NORMAL = 99,           // 普通类
};

typedef NS_ENUM(char, ProductType) {

    TYPE_COMPANY_INTRODUCTION = 'A',    //公司介绍,担保详情
    TYPE_RISK_DISCLOSURE = 'C',         //风险揭示
    TYPE_DISCLAIMER = 'D',              //免责声明
    TYPE_TRADING_MANUAL = 'E',          //交易说明书
    TYPE_CONTRACT_TEMPLATE = 'Z',       //定向委托协议
};



@class ProjectInfo;

@interface ProductFileInfo : NSObject
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *filepath;
@end

@interface ProductInfo : NSObject

@property (assign, nonatomic) int loanId;

@property (strong, nonatomic) ProjectInfo *projectInfo;     // 项目信息
@property (copy, nonatomic) NSString *riskDisclosure;       // 风险揭示
@property (copy, nonatomic) NSString *disclaimer;           // 免责声明
@property (copy, nonatomic) NSString *tradingManual;        // 交易说明
@property (copy, nonatomic) NSString *contractTemplate;     // 合同模板
@property (strong, nonatomic) NSArray *productFileArray;    // 文件列表
@end


@interface ProjectInfo : NSObject

@property (assign, nonatomic) ProjectType type;
@property (readonly, nonatomic) BOOL empty;

@property (copy, nonatomic) NSString *serialNumber; // 项目编号
@property (copy, nonatomic) NSString *name;         // 项目名称
@property (copy, nonatomic) NSString *term;         // 资产期限
@property (copy, nonatomic) NSString *content;      // 项目内容
@property (copy, nonatomic) NSString *introduction; // 项目介绍
@property (assign, nonatomic) double amount;        // 资产规模
@property (assign, nonatomic) double interestRate;  // 资产收益率

@end


