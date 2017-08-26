//
//  MSInsuranceDetailInfoCell.m
//  Sword
//
//  Created by lee on 2017/8/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailInfoCell.h"
#import "NSDate+Add.h"
#import "MSCheckInfoUtils.h"
#import "TimeUtils.h"

@interface MSInsuranceDetailInfoCell()<UITextFieldDelegate>

@property (strong, nonatomic) UILabel *lbYear;
@property (strong, nonatomic) UITextField *email;
@property (strong, nonatomic) UIButton *btnReduce;
@property (strong, nonatomic) UIButton *btnAdd;
@property (strong, nonatomic) UILabel *lbCount;
@property (assign, nonatomic) int count;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UITextField *tfDate;
@property (strong, nonatomic) UIView *vEmailPanel;
@property (strong, nonatomic) UIView *vCopiesSelector;
@property (strong, nonatomic) UILabel *lbCopyValue;

@end

@implementation MSInsuranceDetailInfoCell

+ (MSInsuranceDetailInfoCell *)cellWithTableView:(UITableView *)tableView {

    NSString *reuseId = @"DetailInfo";
    MSInsuranceDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSInsuranceDetailInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *lbDate = [self getLabel];
        lbDate.text = @"保障期限";
        [self.contentView addSubview:lbDate];
        [lbDate autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbDate autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:14];
        
        self.lbYear = [self getLabel];
        [self.contentView addSubview:self.lbYear];
        [self.lbYear autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbYear autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbDate];
        
        UIView *la = [UIView newAutoLayoutView];
        la.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.contentView addSubview:la];
        [la autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [la autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [la autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbDate withOffset:14];
        [la autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *effective = [self getLabel];
        effective.text = @"生效日期";
        [self.contentView addSubview:effective];
        [effective autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:la withOffset:14];
        [effective autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [effective autoSetDimension:ALDimensionWidth toSize:60];
        
        self.tfDate = [UITextField newAutoLayoutView];
        self.tfDate.font = [UIFont systemFontOfSize:12];
        self.tfDate.textAlignment = NSTextAlignmentRight;
        self.tfDate.placeholder = @"选择日期";
        self.tfDate.inputView = self.datePicker;
        [self.contentView addSubview:self.tfDate];
        [self.tfDate autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.tfDate autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:effective];
        [self.tfDate autoAlignAxis:ALAxisHorizontal toSameAxisOfView:effective];
        
        UIView *lb = [UIView newAutoLayoutView];
        lb.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.contentView addSubview:lb];
        [lb autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lb autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lb autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:effective withOffset:14];
        [lb autoSetDimension:ALDimensionHeight toSize:1];

        self.vEmailPanel = [UIView newAutoLayoutView];
        self.vEmailPanel.clipsToBounds = YES;
        [self.contentView addSubview:self.vEmailPanel];
        [self.vEmailPanel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.vEmailPanel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lb];
        [self.vEmailPanel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];

        UILabel *mail = [self getLabel];
        mail.text = @"投保人邮箱";
        [self.vEmailPanel addSubview:mail];
        [mail autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [mail autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:14];
        [mail autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:14];
        [mail autoSetDimension:ALDimensionWidth toSize:80];
        
        self.email = [[UITextField alloc] init];
        self.email.font = [UIFont systemFontOfSize:12];
        self.email.placeholder = @"请输入邮箱";
        self.email.textAlignment = NSTextAlignmentRight;
        self.email.delegate = self;
        [self.vEmailPanel addSubview:self.email];
        [self.email autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:mail withOffset:8];
        [self.email autoAlignAxis:ALAxisHorizontal toSameAxisOfView:mail];
        [self.email autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        
        UIView *lc = [UIView newAutoLayoutView];
        lc.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.vEmailPanel addSubview:lc];
        [lc autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lc autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lc autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.vEmailPanel withOffset:0];
        [lc autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *count = [self getLabel];
        count.text = @"购买份数";
        [self.contentView addSubview:count];
        [count autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lc withOffset:14];
        [count autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];

        self.vCopiesSelector = [UIView newAutoLayoutView];
        [self.contentView addSubview:self.vCopiesSelector];
        [self.vCopiesSelector autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.vCopiesSelector autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:count];
        [self.vCopiesSelector autoAlignAxis:ALAxisHorizontal toSameAxisOfView:count];
        [self.vCopiesSelector autoSetDimension:ALDimensionHeight toSize:48];

        [self.vCopiesSelector addSubview:self.btnAdd];
        [self.btnAdd autoSetDimensionsToSize:CGSizeMake(24, 24)];
        [self.btnAdd autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.vCopiesSelector];
        [self.btnAdd autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        
        [self.vCopiesSelector addSubview:self.lbCount];
        [self.lbCount autoSetDimensionsToSize:CGSizeMake(64, 24)];
        [self.lbCount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:count];
        [self.lbCount autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.btnAdd withOffset:-16];
        
        [self.vCopiesSelector addSubview:self.btnReduce];
        [self.btnReduce autoSetDimensionsToSize:CGSizeMake(24, 24)];
        [self.btnReduce autoAlignAxis:ALAxisHorizontal toSameAxisOfView:count];
        [self.btnReduce autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.lbCount withOffset:-16];

        self.lbCopyValue = [self getLabel];
        [self.contentView addSubview:self.lbCopyValue];
        self.lbCopyValue.text = @"1";
        [self.lbCopyValue autoAlignAxis:ALAxisHorizontal toSameAxisOfView:count];
        [self.lbCopyValue autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        self.lbCopyValue.hidden = YES;
        
        UIView *ld = [UIView newAutoLayoutView];
        ld.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.contentView addSubview:ld];
        [ld autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [ld autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [ld autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [ld autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:count withOffset:14];
    }

    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![MSCheckInfoUtils emailCheckout:textField.text]) {
        [MSToast show:@"输入正确邮箱"];
        return;
    }
    self.viewModel.mail = textField.text;
}


- (void)getDate:(UIDatePicker *)sender {
    
    if (sender.date.day-[NSDate date].day<1) {
        [MSToast show:@"时间不能小于一天"];
        return;
    }
    
    NSTimeInterval time = [sender.date timeIntervalSince1970];
    self.viewModel.effectiveDate = time*1000;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy年MM月dd日";
    self.tfDate.text = [formatter stringFromDate:sender.date];
    
}

- (void)changeCount:(UIButton *)sender {

    switch (sender.tag) {
        case 0: {
            if (self.count < self.viewModel.detail.copiesLimit || !self.viewModel.detail.copiesLimit) {
                self.count++;
            }
            self.lbCount.text = [NSString stringWithFormat:@"%d",self.count];
        }
            break;
        case 1: {
            if (self.count<=1) {
                return;
            }
            self.count--;
            self.lbCount.text = [NSString stringWithFormat:@"%d",self.count];
        }
            break;
        default:
            break;
    }
    self.viewModel.count = self.count;
    if (self.updateCountBlock) {
        self.updateCountBlock(self.count);
    }
}

- (void)setDetail:(InsuranceDetail *)detail {
    _detail = detail;
    
    if (!detail) {
        return;
    }
    
    TermInfo *term = _detail.termOptions.firstObject;
    self.lbYear.text = [NSString stringWithFormat:@"%d%@", term.termCount, term.term];
    if (_detail.copiesLimit == 1) {
        self.vCopiesSelector.hidden = YES;
        self.lbCopyValue.hidden = NO;
    } else {
        self.lbCopyValue.hidden = YES;
        self.vCopiesSelector.hidden = NO;
    }
    
    if (_detail.effectiveDate) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy年MM月dd日";
        NSDate *date = [TimeUtils convertToUTCDate:[NSDate dateWithTimeIntervalSince1970:_detail.effectiveDate/1000.0]];
        self.tfDate.text = [formatter stringFromDate:date];
        self.tfDate.userInteractionEnabled = NO;
        self.viewModel.effectiveDate = _detail.effectiveDate;
    } else {
        NSDate *date = [TimeUtils date];
        self.tfDate.text = [NSString stringWithFormat:@"%04ld年%02ld月%02ld日",(long)date.year,(long)(date).month,((long)date.day+1)];
        NSTimeInterval time = [date timeIntervalSince1970]+24*60*60;
        self.viewModel.effectiveDate = time*1000;
    }
    
    if (!_detail.needMail) {
        [self.vEmailPanel autoSetDimension:ALDimensionHeight toSize:0];
    }
    
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(getDate:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (UILabel *)getLabel {
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor ms_colorWithHexString:@"333333"];
    return label;
}

- (UILabel *)lbCount {
    if (!_lbCount) {
        _lbCount = [UILabel newAutoLayoutView];
        _lbCount.font = [UIFont systemFontOfSize:14];
        _lbCount.textAlignment = NSTextAlignmentCenter;
        _lbCount.layer.borderColor = [UIColor ms_colorWithHexString:@"CCCCCC"].CGColor;
        _lbCount.layer.borderWidth = 1;
        _lbCount.layer.cornerRadius = 4;
        _lbCount.layer.masksToBounds = YES;
        _count = 1;
        _lbCount.text = [NSString stringWithFormat:@"%d",self.count];
    }
    return _lbCount;
}

- (UIButton *)btnReduce {
    if (!_btnReduce) {
        _btnReduce = [UIButton newAutoLayoutView];
        _btnReduce.tag = 1;
        [_btnReduce setBackgroundImage:[UIImage imageNamed:@"produce_btn_minus_default"] forState:UIControlStateNormal];
        [_btnReduce setBackgroundImage:[UIImage imageNamed:@"produce_btn_minus_pressed"] forState:UIControlStateSelected];
        [_btnReduce addTarget:self action:@selector(changeCount:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnReduce;
}

- (UIButton *)btnAdd {

    if (!_btnAdd) {
        _btnAdd = [UIButton newAutoLayoutView];
        _btnAdd.tag = 0;
        [_btnAdd setBackgroundImage:[UIImage imageNamed:@"produce_btn_add_default"] forState:UIControlStateNormal];
        [_btnAdd setBackgroundImage:[UIImage imageNamed:@"produce_btn_add_pressed"] forState:UIControlStateSelected];
        [_btnAdd addTarget:self action:@selector(changeCount:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAdd;
}

@end
