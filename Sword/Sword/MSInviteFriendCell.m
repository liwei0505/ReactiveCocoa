//
//  MSInviteFriendCell.m
//  Sword
//
//  Created by lee on 16/7/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInviteFriendCell.h"
#import "NSDate+Add.h"
#import "NSString+Ext.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface MSInviteFriendCell()
@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) UILabel *lbReward;
@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UIView  *topLine;
@end

@implementation MSInviteFriendCell
+ (MSInviteFriendCell *)cellWithTableView:(UITableView *)tableView {
    MSInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSInviteFriendCell"];
    if (!cell) {
        cell = [[MSInviteFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSInviteFriendCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.lbName = [UILabel newAutoLayoutView];
        self.lbName.font = [UIFont boldSystemFontOfSize:14];
        self.lbName.textAlignment = NSTextAlignmentCenter;
        self.lbName.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbName];
        [self.lbName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbName autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:16];
        [self.lbName autoSetDimension:ALDimensionHeight toSize:20];
        [self.lbName autoSetDimension:ALDimensionWidth toSize:screenWidth * 0.5 relation:NSLayoutRelationLessThanOrEqual];
        
        self.lbReward = [UILabel newAutoLayoutView];
        self.lbReward.font = [UIFont boldSystemFontOfSize:14];
        self.lbReward.textAlignment = NSTextAlignmentCenter;
        self.lbReward.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbReward];
        [self.lbReward autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbReward autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbName];
        [self.lbReward autoSetDimension:ALDimensionHeight toSize:28];
        
        self.lbTime = [UILabel newAutoLayoutView];
        self.lbTime.font = [UIFont systemFontOfSize:10];
        self.lbTime.textAlignment = NSTextAlignmentCenter;
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:self.lbTime];
        [self.lbTime autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbTime autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbName withOffset:2];
        [self.lbTime autoSetDimension:ALDimensionHeight toSize:14];
        
        UILabel *lbTips = [UILabel newAutoLayoutView];
        lbTips.font = [UIFont systemFontOfSize:10];
        lbTips.textAlignment = NSTextAlignmentCenter;
        lbTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        lbTips.text = @"累计奖励(元)";
        [self.contentView addSubview:lbTips];
        [lbTips autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
        [lbTips autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbTime];
        [lbTips autoSetDimension:ALDimensionHeight toSize:14];
        
        self.topLine = [UIView newAutoLayoutView];
        self.topLine.backgroundColor = RGB(235, 235, 235);
        [self.contentView addSubview:self.topLine];
        [self.topLine autoSetDimension:ALDimensionHeight toSize:0.5];
        [self.topLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.topLine autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.topLine autoPinEdgeToSuperviewEdge:ALEdgeRight];
    }
    return self;
}

- (void)updateWithFriendInfo:(FriendInfo *)friendInfo index:(NSInteger)index {
    self.topLine.hidden = ((index == 0) ? YES : NO);
    self.lbName.text = friendInfo.nickname;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:friendInfo.registerDate/1000];
    self.lbTime.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute,(long)date.second];
    self.lbReward.text = [NSString convertMoneyFormate:friendInfo.totalReward.doubleValue];
    
}

@end
