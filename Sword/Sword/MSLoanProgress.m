//
//  MSLoanProgress.m
//  nvwkjv
//
//  Created by 聂文辉 on 2017/6/10.
//  Copyright © 2017年 snow_nwh. All rights reserved.
//

#import "MSLoanProgress.h"
#import "UIView+FrameUtil.h"
#import "NSString+Ext.h"
#import "UIColor+StringColor.h"
#import "NSDate+Add.h"

@interface MSLoanProgress ()
@property(nonatomic, strong)UILabel *lbtips;
@property(nonatomic, strong)UIImageView *imageview;
@end

@implementation MSLoanProgress

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.4];
        [self addSubview:line];
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - 7, 14, 14)];
        self.imageview.image = [UIImage imageNamed:@"ms_progress_circle"];
        [self addSubview:self.imageview];
        
        NSString *tips = @"已售-- 剩余可投--元";
        CGSize size = [self sizewithcontent:tips];
        self.lbtips = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.imageview.frame) - size.height - 3, size.width, size.height)];
        self.lbtips.font = [UIFont systemFontOfSize:10];
        self.lbtips.text = tips;
        self.lbtips.textColor = [UIColor whiteColor];
        self.lbtips.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbtips];
        
        self.lbtips.hidden = YES;
        self.imageview.hidden = YES;
        
    }
    return self;
}

- (void)updateWithLoanDetail:(LoanDetail *)loanDetail {
    
    self.lbtips.hidden = NO;
    switch (loanDetail.baseInfo.status){
        case LOAN_STATUS_WILL_START:
        {
            self.imageview.hidden = YES;
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:loanDetail.baseInfo.raiseBeginTime/1000];
            self.lbtips.text = [NSString stringWithFormat:@"%ld月%02ld日 %02ld:%02ld 开抢",(long)date.month,(long)date.day,(long)date.hour,(long)date.minute];
            CGSize size = [self sizewithcontent:self.lbtips.text];
            self.lbtips.frame = CGRectMake(0, CGRectGetMinY(self.imageview.frame) - size.height - 3, self.width, size.height);
            
            break;
        }
        case LOAN_STATUS_INVEST_NOW:
        {
            self.imageview.hidden = NO;
            
            NSString *amountStr = [NSString convertMoneyFormate:loanDetail.baseInfo.subjectAmount];
            NSString *progressStr = nil;
            if (loanDetail.baseInfo.progress == 100) {
                progressStr = [NSString stringWithFormat:@"%0.f%%",loanDetail.baseInfo.progress];
            }else{
                progressStr = [NSString stringWithFormat:@"%.1f%%",floor(loanDetail.baseInfo.progress*10)/10];
            }
            
            NSString *tips = [NSString stringWithFormat:@"已售%@ 剩余可投%@元",progressStr,amountStr];
            CGSize size = [self sizewithcontent:tips];
            double centerX = self.width * (loanDetail.baseInfo.progress / 100);
            self.lbtips.text = tips;
            double duration = 0.75;
            [UIView animateWithDuration:duration animations:^{
                if (centerX <= self.imageview.width / 2.0) {
                    self.imageview.x = 0;
                }else if (centerX >= self.width - self.imageview.width / 2.0){
                    self.imageview.x = self.width - self.imageview.width;
                }else {
                    self.imageview.centerX = centerX;
                }
            }];
            self.lbtips.size = size;
            self.lbtips.y = CGRectGetMinY(self.imageview.frame) - size.height - 3;
            [UIView animateWithDuration:duration animations:^{
                if (size.width / 2.0 >= self.imageview.centerX) {
                    self.lbtips.x = 0;
                }else if (self.imageview.centerX >= self.width - size.width/2.0){
                    self.lbtips.x = self.width - size.width;
                }else {
                    self.lbtips.centerX = self.imageview.centerX;
                }
                
            }];
             break;
        }
        default:
        {
            self.imageview.hidden = YES;
            
            self.lbtips.text = @"已售100%";
            CGSize size = [self sizewithcontent:self.lbtips.text];
            self.lbtips.frame = CGRectMake(0, CGRectGetMinY(self.imageview.frame) - size.height - 3, self.width, size.height);
            break;
        }
    }
}

- (CGSize)sizewithcontent:(NSString *)string {
    return [string sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}];
}

@end
