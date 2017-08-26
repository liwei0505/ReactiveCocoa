//
//  MSNewPointCell.m
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewPointCell.h"
#import "PointRecord.h"
#import "PureLayout.h"
#import "UIColor+StringColor.h"

static NSString *cellId = @"MSNewPointCell";

@interface MSNewPointCell ()
@property (strong, nonatomic) UILabel *lbPointName;
@property (strong, nonatomic) UILabel *lbPoint;
@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UILabel *lbStatus;
@end

@implementation MSNewPointCell

+ (MSNewPointCell *)cellWithTableView:(UITableView *)tableView{
    
    MSNewPointCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MSNewPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lbPointName = [UILabel newAutoLayoutView];
        self.lbPointName.textColor = [UIColor ms_colorWithHexString:@"#535353"];
        self.lbPointName.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:self.lbPointName];
        [self.lbPointName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [self.lbPointName autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [self.lbPointName autoSetDimension:ALDimensionHeight toSize:15];
        
        self.lbPoint = [UILabel newAutoLayoutView];
        self.lbPoint.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
        self.lbPoint.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:self.lbPoint];
        [self.lbPoint autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbPointName];
        [self.lbPoint autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
        [self.lbPoint autoSetDimension:ALDimensionHeight toSize:21];
        
        self.lbTime = [UILabel newAutoLayoutView];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#AAAAAA"];
        self.lbTime.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.lbTime];
        [self.lbTime autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [self.lbTime autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        [self.lbTime autoSetDimension:ALDimensionHeight toSize:13];
        
        self.lbStatus = [UILabel newAutoLayoutView];
        self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#848484"];
        self.lbStatus.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.lbStatus];
        [self.lbStatus autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbTime];
        [self.lbStatus autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
        [self.lbStatus autoSetDimension:ALDimensionHeight toSize:13];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#AAAAAA"];
        [self.contentView addSubview:line];
        [line autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
        [line autoSetDimension:ALDimensionHeight toSize:0.5];
    }
    return self;
}

- (void)setPointRecord:(PointRecord *)pointRecord{
    _pointRecord = pointRecord;
    
    self.lbPointName.text = pointRecord.pointName;
    if (pointRecord.point > 0) {
        self.lbPoint.text = [NSString stringWithFormat:@"+%d",pointRecord.point];
    } else {
        self.lbPoint.text = [NSString stringWithFormat:@"%d",pointRecord.point];
    }
    self.lbTime.text = pointRecord.receivedDate;
    self.lbStatus.text = pointRecord.status;
}
@end
