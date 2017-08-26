//
//  MSLoanTimeLine.m
//  Sword
//
//  Created by msj on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSLoanTimeLine.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "TimeUtils.h"
#import "NSDate+Add.h"

typedef NS_ENUM(NSInteger, POINT) {
    POINT_NORMAL,
    POINT_SELECTED
};

#pragma mark - MSPoint
@interface MSPoint : UIView
@property (assign, nonatomic) POINT type;
@end

@implementation MSPoint
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.width/2.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.type = POINT_NORMAL;
    }
    return self;
}

- (void)setType:(POINT)type {
    if (type == POINT_NORMAL) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
        self.layer.borderColor = [UIColor ms_colorWithHexString:@"#CCCCCC"].CGColor;
    } else {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#BBB9FF"];
        self.layer.borderColor = [UIColor ms_colorWithHexString:@"#4945B7"].CGColor;

    }
}
@end

#pragma mark - MSLine
@interface MSLine : UIView
@property (assign, nonatomic) CGFloat progress;
@end

@interface MSLine ()
@property (strong, nonatomic) UIView *progressView;
@end

@implementation MSLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
        self.progressView.backgroundColor = [UIColor ms_colorWithHexString:@"#4945B7"];
        [self addSubview:self.progressView];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    self.progressView.width = self.width * progress;
}

@end

#pragma mark - MSLoanTimeLine
@interface MSLoanTimeLine ()
@property (strong, nonatomic) NSMutableArray *pionts;
@property (strong, nonatomic) NSMutableArray *lines;

@property (strong, nonatomic) UILabel *lbTimeTips;
@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UILabel *lbStartTimeTips;
@property (strong, nonatomic) UILabel *lbStartTime;
@property (strong, nonatomic) UILabel *lbEndTimeTips;
@property (strong, nonatomic) UILabel *lbEndTime;
@property (strong, nonatomic) UILabel *lbMoneyBackTimeTips;
@property (strong, nonatomic) UILabel *lbMoneyBackTime;
@end

@implementation MSLoanTimeLine

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 10, self.width, 10)];
        bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        [self addSubview:bottomLine];
        
        CGFloat width = self.width / 4.0;
        self.lbTimeTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, width, 14)];
        self.lbTimeTips.text = @"--";
        self.lbTimeTips.textAlignment = NSTextAlignmentCenter;
        self.lbTimeTips.font = [UIFont systemFontOfSize:10];
        self.lbTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self addSubview:self.lbTimeTips];
        
        self.lbStartTimeTips = [[UILabel alloc] initWithFrame:CGRectMake(width, 24, width, 14)];
        self.lbStartTimeTips.text = @"起息日";
        self.lbStartTimeTips.textAlignment = NSTextAlignmentCenter;
        self.lbStartTimeTips.font = [UIFont systemFontOfSize:10];
        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self addSubview:self.lbStartTimeTips];
        
        self.lbEndTimeTips = [[UILabel alloc] initWithFrame:CGRectMake(width*2, 24, width, 14)];
        self.lbEndTimeTips.text = @"止息日";
        self.lbEndTimeTips.textAlignment = NSTextAlignmentCenter;
        self.lbEndTimeTips.font = [UIFont systemFontOfSize:10];
        self.lbEndTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self addSubview:self.lbEndTimeTips];
        
        self.lbMoneyBackTimeTips = [[UILabel alloc] initWithFrame:CGRectMake(width*3, 24, width, 14)];
        self.lbMoneyBackTimeTips.text = @"回款到账";
        self.lbMoneyBackTimeTips.textAlignment = NSTextAlignmentCenter;
        self.lbMoneyBackTimeTips.font = [UIFont systemFontOfSize:10];
        self.lbMoneyBackTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self addSubview:self.lbMoneyBackTimeTips];
        
        self.lbTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 62, width, 14)];
        self.lbTime.text = @"--:--:--";
        self.lbTime.textAlignment = NSTextAlignmentCenter;
        self.lbTime.font = [UIFont systemFontOfSize:10];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];//4229B3
        [self addSubview:self.lbTime];
        
        self.lbStartTime = [[UILabel alloc] initWithFrame:CGRectMake(width, 62, width, 14)];
        self.lbStartTime.text = @"--";
        self.lbStartTime.textAlignment = NSTextAlignmentCenter;
        self.lbStartTime.font = [UIFont systemFontOfSize:10];
        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self addSubview:self.lbStartTime];
        
        self.lbEndTime = [[UILabel alloc] initWithFrame:CGRectMake(width*2, 62, width, 14)];
        self.lbEndTime.text = @"--";
        self.lbEndTime.textAlignment = NSTextAlignmentCenter;
        self.lbEndTime.font = [UIFont systemFontOfSize:10];
        self.lbEndTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self addSubview:self.lbEndTime];
        
        self.lbMoneyBackTime = [[UILabel alloc] initWithFrame:CGRectMake(width*3, 62, width, 14)];
        self.lbMoneyBackTime.text = @"--";
        self.lbMoneyBackTime.textAlignment = NSTextAlignmentCenter;
        self.lbMoneyBackTime.font = [UIFont systemFontOfSize:10];
        self.lbMoneyBackTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self addSubview:self.lbMoneyBackTime];
        
        
        self.pionts = [NSMutableArray array];
        self.lines = [NSMutableArray array];
        
        CGFloat pointW = 9;
        CGFloat pointX = (self.width - 4 * pointW) / 8.0;
        for (int i = 0; i < 4; i++) {
            MSPoint *point = [[MSPoint alloc] initWithFrame:CGRectMake(pointX + i * (2*pointX + pointW), 46.5, pointW, pointW)];
            [self addSubview:point];
            [self.pionts addObject:point];
        }
        
        CGFloat distance = 18;
        CGFloat lineW = width - distance;
        CGFloat lineX = (self.width - 3 * lineW - 2 * distance) / 2.0;
        for (int i = 0; i < 3; i++) {
            MSLine *line = [[MSLine alloc] initWithFrame:CGRectMake(lineX + i * (lineW + distance), 51, lineW, 1)];
            [self addSubview:line];
            [self.lines addObject:line];
        }
    }
    return self;
}

- (void)setLoanDetail:(LoanDetail *)loanDetail {
    _loanDetail = loanDetail;
    
    self.lbStartTime.text = loanDetail.interestBeginTime;
    self.lbEndTime.text = loanDetail.interestEndTime;
    self.lbMoneyBackTime.text = loanDetail.repayNumber;
    
    [self drawTimeLine];
}

- (void)drawTimeLine {
    
    [self setDefaultColor];
    
    switch (self.loanDetail.baseInfo.status) {
        case LOAN_STATUS_WILL_START:
        {
            self.lbTimeTips.text = @"募集开始日";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.loanDetail.baseInfo.raiseBeginTime/1000];
            self.lbTime.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)date.year,(long)date.month,(long)date.day];
            break;
        }
        case LOAN_STATUS_INVEST_NOW:
        {
            
            NSTimeInterval interVal = self.loanDetail.baseInfo.raiseEndTime/1000 - [NSDate date].timeIntervalSince1970;
            if (interVal > 24 * 3600) {
                self.lbTimeTips.text = @"募集结束日";
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.loanDetail.baseInfo.raiseEndTime/1000];
                self.lbTime.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)date.year,(long)date.month,(long)date.day];
            } else {
                self.lbTimeTips.text = @"募集倒计时";
                NSTimeInterval inter = self.loanDetail.baseInfo.deadline - [TimeUtils date].timeIntervalSince1970;
                if (inter > 0) {
                    [self countdown:self.loanDetail.baseInfo.deadline];
                }else {
                    self.lbTime.text = @"00:00:00";
                }
            }
            self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
            self.lbTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
            [self drawPointWithCount:1];
            break;
        }
        default:
        {
            if (self.loanDetail.fullTime == 0) {
                self.lbTimeTips.text = @"募集已结束";
                self.lbTime.text = @"00:00:00";
                self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                self.lbTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                [self drawPointWithCount:1];
                MSLine *line = self.lines.firstObject;
                line.progress = 0.5;
            } else {
                self.lbTimeTips.text = @"募集完成日";
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.loanDetail.fullTime/1000];
                self.lbTime.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)date.year,(long)date.month,(long)date.day];
                self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                self.lbTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                
                if (![self formatterWithString:self.loanDetail.interestBeginTime]) {
                    [self drawPointWithCount:1];
                    [self drawLineWithCount:1];
                } else {
                    NSTimeInterval beginTime = [self formatterWithString:self.loanDetail.interestBeginTime].timeIntervalSince1970;
                    NSTimeInterval endTime = [self formatterWithString:self.loanDetail.interestEndTime].timeIntervalSince1970;
                    NSTimeInterval backMoneyTime = [self formatterWithString:self.loanDetail.repayNumber].timeIntervalSince1970;
                    NSTimeInterval nowTime = [NSDate date].timeIntervalSince1970;
                    NSTimeInterval during = 24 * 3600;
                    
                    if (nowTime - beginTime < 0) {
                        [self drawPointWithCount:1];
                        [self drawLineWithCount:1];
                    }else if (nowTime - beginTime <= during) {
                        [self drawPointWithCount:2];
                        [self drawLineWithCount:1];
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }else if (nowTime - beginTime > during && nowTime - endTime < -during) {
                        [self drawPointWithCount:2];
                        [self drawLineWithCount:1];
                        MSLine *line2 = self.lines[1];
                        line2.progress = 0.5;
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }else if (nowTime - endTime >= -during && nowTime - endTime < 0) {
                        [self drawPointWithCount:2];
                        [self drawLineWithCount:2];
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }else if (nowTime - endTime >= 0 && nowTime - endTime <= during) {
                        [self drawPointWithCount:3];
                        [self drawLineWithCount:2];
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }else if (nowTime - endTime > during && nowTime - backMoneyTime <= -during) {
                        [self drawPointWithCount:3];
                        [self drawLineWithCount:2];
                        MSLine *line3 = self.lines[2];
                        line3.progress = 0.5;
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }else if (nowTime - backMoneyTime > -during && nowTime - backMoneyTime < during) {
                        [self drawPointWithCount:3];
                        [self drawLineWithCount:3];
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }else {
                        [self drawPointWithCount:4];
                        [self drawLineWithCount:3];
                        self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbEndTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbMoneyBackTime.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                        self.lbMoneyBackTimeTips.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
                    }
                    
                }
            }
            break;
        }
    }
}

- (void)countdown:(NSTimeInterval)deadline {
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        NSTimeInterval interval = deadline - [TimeUtils date].timeIntervalSince1970;
        BOOL continueCountdown = interval > 0;
        
        self.lbTime.text = [self getTimeWithInterval:interval];
        
        if (continueCountdown) {
            [self countdown:deadline];
        } else {
            if (self.loanDetail.baseInfo.status == LOAN_STATUS_WILL_START) {
                self.loanDetail.baseInfo.status = LOAN_STATUS_INVEST_NOW;
            } else if (self.loanDetail.baseInfo.status == LOAN_STATUS_INVEST_NOW) {
                self.loanDetail.baseInfo.status = LOAN_STATUS_COMPLETED;
            }
            if (self.countdownTimeoutBlock) {
                self.countdownTimeoutBlock();
            }
        }
    });
}

- (NSDate *)formatterWithString:(NSString *)str {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter dateFromString:str];
}

- (void)setDefaultColor {
    self.lbTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbStartTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbEndTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbMoneyBackTimeTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbStartTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbEndTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbMoneyBackTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    for (MSPoint *point in self.pionts) {
        point.type = POINT_NORMAL;
    }
    for (MSLine *line in self.lines) {
        line.progress = 0;
    }
}

- (void)drawPointWithCount:(NSInteger)count {
    for (int i = 0; i < self.pionts.count; i++) {
        MSPoint *point = self.pionts[i];
        if (i < count) {
            point.type = POINT_SELECTED;
        }else {
            point.type = POINT_NORMAL;
        }
    }
}

- (void)drawLineWithCount:(NSInteger)count {
    for (int i = 0; i < self.lines.count; i++) {
        MSLine *line = self.lines[i];
        if (i < count) {
            line.progress = 1;
        }else {
            line.progress = 0;
        }
    }
}

- (NSString *)getTimeWithInterval:(long)interval {
    
    if (interval <= 0) {
        return @"00:00:00";
    }
    
    int days = (int)interval / (3600 * 24);
    interval = interval % (3600 * 24);
    int hours = (int)interval / 3600;
    interval = interval % 3600;
    int minutes = (int)interval / 60;
    int seconds = (int)interval % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", days * 24 + hours, minutes, seconds];
}
@end
