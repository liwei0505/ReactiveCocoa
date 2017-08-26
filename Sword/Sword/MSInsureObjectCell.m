//
//  MSInsureObjectCell.m
//  Sword
//
//  Created by lee on 2017/8/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsureObjectCell.h"
#import "MSCheckInfoUtils.h"
#import "UIImage+color.h"

@interface MSInsureObjectCell()<UITextFieldDelegate>
@property (strong, nonatomic) UIView *otherView;
@property (strong, nonatomic) UISwitch *objectSwitch;
@property (strong, nonatomic) UITextField *tfName;
@property (strong, nonatomic) UITextField *tfIdNumber;
@property (strong, nonatomic) UILabel *lbDate;
@property (strong, nonatomic) UIButton *currentBtn;
@property (strong, nonatomic) UILabel *lbSelf;

@end

@implementation MSInsureObjectCell

+ (MSInsureObjectCell *)cellWithTableView:(UITableView *)tableView {
    NSString *reuseId = @"InsureObject";
    MSInsureObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSInsureObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lbSelf = [self getLabel:@"被保险人为本人"];
        [self.contentView addSubview:self.lbSelf];
        [self.lbSelf autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbSelf autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:14];
        
        [self.contentView addSubview:self.objectSwitch];
        [self.objectSwitch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.objectSwitch autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbSelf];
        
    }
    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.tfName) {
        self.viewModel.info.name = textField.text;
    } else if (textField == self.tfIdNumber) {
        NSString *number = textField.text;
        if (![MSCheckInfoUtils identityCardCheckout:number]) {
            [MSToast show:@"请输入正确的身份证号"];
            return;
        }
        
        if (self.viewModel.detail.genderLimit) {
            NSString *gender = [textField.text substringWithRange:NSMakeRange(textField.text.length-2, 1)];
            if (gender.integerValue != self.viewModel.detail.genderLimit) {
                [MSToast show:@"性别与要求不符"];
            }
        }
        
        self.lbDate.text = [self convertToBirthDate:number];
        self.viewModel.info.certificateId = number;
    }
}

- (void)switchChange:(UISwitch *)sender {
    self.viewModel.typeOther = !sender.on;
    if (sender.on) {
        [self.otherView removeFromSuperview];
        self.viewModel.info.relationship = 1;
        self.viewModel.info = nil;
    } else {
        [self.contentView addSubview:self.otherView];
        [self.otherView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.objectSwitch withOffset:8];
        [self.otherView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.otherView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.otherView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    }
    if (self.switchBlock) {
        self.switchBlock(sender.on);
    }
}

- (void)relationSelected:(UIButton *)sender {
    if (self.currentBtn) {
        self.currentBtn.selected = !self.currentBtn.selected;
    }
    sender.selected = !sender.selected;
    self.currentBtn = sender;
    self.viewModel.info.relationship = sender.tag;
}

#pragma mark - private

- (NSString *)convertToBirthDate:(NSString *)string {

    NSString *year = [string substringWithRange:NSMakeRange(6, 4)];
    NSString *month = [string substringWithRange:NSMakeRange(10, 2)];
    NSString *day = [string substringWithRange:NSMakeRange(12, 2)];
    NSString *date = [NSString stringWithFormat:@"%@年%@月%@日",year,month,day];
    return date;
}

- (UILabel *)getLabel:(NSString *)title {
    UILabel *label = [UILabel newAutoLayoutView];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor ms_colorWithHexString:@"333333"];
    return label;
}

- (UIView *)getLine {
    UIView *line = [UIView newAutoLayoutView];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
    return line;
}

- (NSString *)getRelation:(NSInteger)relation {
    switch (relation) {
        case 2:
            return @"父母";
        case 3:
            return @"子女";
        case 4:
            return @"配偶";
        case 9:
            return @"其他";
        default:
            return @"";
    }
}

#pragma mark - lazy

- (UIView *)otherView {
    if (!_otherView) {
        _otherView = [UIView newAutoLayoutView];
        UIView *la = [self getLine];
        [_otherView addSubview:la];
        [la autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [la autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [la autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [la autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *lbName = [self getLabel:@"被保险人姓名"];
        [_otherView addSubview:lbName];
        [lbName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:la withOffset:14];
        [lbName autoSetDimension:ALDimensionWidth toSize:90];
        
        self.tfName = [UITextField newAutoLayoutView];
        self.tfName.font = [UIFont systemFontOfSize:12];
        self.tfName.textAlignment = NSTextAlignmentRight;
        self.tfName.placeholder = @"请输入真实姓名";
        self.tfName.delegate = self;
        [_otherView addSubview:self.tfName];
        [self.tfName autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.tfName autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbName];
        [self.tfName autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbName];
        
        UIView *lb = [self getLine];
        [_otherView addSubview:lb];
        [lb autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lb autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbName withOffset:14];
        [lb autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lb autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *lbRelation = [self getLabel:@"为谁投保"];
        [_otherView addSubview:lbRelation];
        [lbRelation autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbRelation autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lb withOffset:14];
        [lbRelation autoSetDimension:ALDimensionWidth toSize:84];
        
        if (self.viewModel) {
            
            NSMutableArray *relationArray = [NSMutableArray array];
            [self.viewModel.detail.insurantLimit enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.integerValue != 1) {
                    [relationArray addObject:obj];
                }
            }];
            
            for (int i=(int)(relationArray.count-1); i>=0; i--) {
                if ([relationArray[i] integerValue] == 1) {
                    continue;
                }
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.layer.borderColor = [UIColor ms_colorWithHexString:@"4945B7"].CGColor;
                button.layer.borderWidth = 1;
                button.layer.cornerRadius = 12;
                button.layer.masksToBounds = YES;
                button.titleLabel.font = [UIFont systemFontOfSize:12];
                [button setTitle:[self getRelation:[relationArray[i] integerValue]] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor ms_colorWithHexString:@"4945B7"] forState:UIControlStateNormal];
                UIImage *back = [UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"4945B7"] withSize:CGSizeMake(45, 24)];
                [button setBackgroundImage:back forState:UIControlStateSelected];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                button.tag = [relationArray[i] integerValue];
                [button addTarget:self action:@selector(relationSelected:) forControlEvents:UIControlEventTouchUpInside];
                [_otherView addSubview:button];
                [button autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbRelation];
                [button autoSetDimensionsToSize:CGSizeMake(45, 24)];
                [button autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:(16+50*i)];
                
                if (relationArray.count == 1) {
                    button.selected = YES;
                    button.userInteractionEnabled = NO;
                }
            }
        }
        
        UIView *lc = [self getLine];
        [_otherView addSubview:lc];
        [lc autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lc autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbRelation withOffset:14];
        [lc autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lc autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *lbIdType = [self getLabel:@"证件类型"];
        [_otherView addSubview:lbIdType];
        [lbIdType autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lc withOffset:14];
        [lbIdType autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbIdType autoSetDimension:ALDimensionWidth toSize:84];
        
        UILabel *lbIdCard = [UILabel newAutoLayoutView];
        lbIdCard.text = @"身份证";
        lbIdCard.font = [UIFont systemFontOfSize:12];
        lbIdCard.textColor = [UIColor ms_colorWithHexString:@"CCCCCC"];
        [_otherView addSubview:lbIdCard];
        [lbIdCard autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [lbIdCard autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbIdType];
        
        UIView *ld = [self getLine];
        [_otherView addSubview:ld];
        [ld autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [ld autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbIdType withOffset:14];
        [ld autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [ld autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *lbIdNo = [self getLabel:@"证件号码"];
        [_otherView addSubview:lbIdNo];
        [lbIdNo autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:ld withOffset:14];
        [lbIdNo autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbIdNo autoSetDimension:ALDimensionWidth toSize:84];
        
        self.tfIdNumber = [UITextField newAutoLayoutView];
        self.tfIdNumber.font = [UIFont systemFontOfSize:12];
        self.tfIdNumber.textAlignment = NSTextAlignmentRight;
        self.tfIdNumber.placeholder = @"请输入身份证号码";
        self.tfIdNumber.delegate = self;
        [_otherView addSubview:self.tfIdNumber];
        [self.tfIdNumber autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.tfIdNumber autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbIdNo];
        [self.tfIdNumber autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbIdNo];
        
        UIView *le = [self getLine];
        [_otherView addSubview:le];
        [le autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [le autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbIdNo withOffset:14];
        [le autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [le autoSetDimension:ALDimensionHeight toSize:1];
        
        UILabel *lbBirth = [self getLabel:@"被保人生日"];
        [_otherView addSubview:lbBirth];
        [lbBirth autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:le withOffset:14];
        [lbBirth autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbBirth autoSetDimension:ALDimensionWidth toSize:84];
        
        self.lbDate = [UILabel newAutoLayoutView];
        self.lbDate.font = [UIFont systemFontOfSize:12];
        self.lbDate.textColor = [UIColor ms_colorWithHexString:@"333333"];
        [_otherView addSubview:self.lbDate];
        [self.lbDate autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbDate autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbBirth];
        
    }
    return _otherView;
}

- (void)setDetail:(InsuranceDetail *)detail {
    _detail = detail;
    if (_viewModel.detail.insurantLimit.count == 1) {
        self.objectSwitch.hidden = YES;
        if ([_viewModel.detail.insurantLimit.firstObject integerValue] == 1) {
            self.lbSelf.text = @"被保险人为本人";
        } else {
            self.lbSelf.text = [NSString stringWithFormat:@"被保险人为其他"];//[self getRelation:[viewModel.detail.insurantLimit.firstObject integerValue]]
            [self.contentView addSubview:self.otherView];
            [self.otherView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.objectSwitch withOffset:8];
            [self.otherView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            [self.otherView autoPinEdgeToSuperviewEdge:ALEdgeRight];
            [self.otherView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        }
        self.viewModel.info.relationship = [_viewModel.detail.insurantLimit.firstObject integerValue];
        
    }
    
}

- (UISwitch *)objectSwitch {
    if (!_objectSwitch) {
        _objectSwitch = [[UISwitch alloc] init];
        _objectSwitch.onTintColor = [UIColor ms_colorWithHexString:@"4945B7"];
        _objectSwitch.on = YES;
        [_objectSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _objectSwitch;
}

@end
