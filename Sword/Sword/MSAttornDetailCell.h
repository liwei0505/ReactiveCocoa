//
//  MSAttronDetailCell.h
//  Sword
//
//  Created by haorenjie on 16/6/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSAttornDetailCell : UITableViewCell

typedef NS_ENUM(NSInteger, AttornFieldType) {
    ATTORN_FIELD_EXPECTED_EARNINGS,       // 预期收益
    ATTORN_FIELD_LEFT_TERM,               // 剩余期限
    ATTORN_FIELD_DEBT_VALUE,              // 债权价值
    ATTORN_FIELD_INCOMING_WAY,            // 收益方式
    ATTORN_FIELD_REPAYMENT_RECEIVE_DATE,  // 还款到账日
    // 原项目详情
    ATTORN_FIELD_SCALE_OF_FINANCING,      // 融资规模
    ATTORN_FIELD_ANNUAL_INTEREST,         // 年化收益率
    ATTORN_FIELD_INVEST_TERM,             // 投资期限
    ATTORN_FIELD_REPAYMENT_WAY,           // 还款方式
    ATTORN_FIELD_MIN_INVESTMENT,          // 最小投资单位
    ATTORN_FIELD_VALUE_DATE,              // 起息日
    ATTORN_FIELD_CEASE_DATE,              // 止息日
};

@property (assign, nonatomic) NSInteger type;
@property (weak, nonatomic) IBOutlet UILabel *lbValue;
- (void)updateInfo:(DebtDetail *)debtInfo withIndex:(NSInteger)index;
@end
