
//
//  MSCountDownView.m
//  showTime
//
//  Created by msj on 2016/12/20.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSCountDownView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define DEFAULTCOUNT  60

@interface MSCountDownView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) int defaultCount;

@property (strong, nonatomic) UIView *line;
@end

@implementation MSCountDownView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupInit];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit{
    
    self.layer.cornerRadius = 3;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    
    self.lbTitle = [[UILabel alloc] initWithFrame:self.bounds];
    self.lbTitle.font = [UIFont systemFontOfSize:12];
    self.lbTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.lbTitle];
    
    self.line = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 1, self.height)];
    self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [self addSubview:self.line];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.defaultCount = DEFAULTCOUNT;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(willCountdown)]];
    self.style = MSCountDownStyleNormal;
}

- (void)setStyle:(MSCountDownStyle)style {
    _style = style;
    self.line.hidden = (style == MSCountDownStylePay);
    self.currentMode = MSCountDownViewModeNormal;
}

- (void)setCount:(int)count
{
    if (count <= 0) {
        NSLog(@"倒计时count应该大于0");
        return;
    }
    _count = count;
    self.defaultCount = count;
}

- (void)startCountdownWithMode:(MSCountDownViewMode)mode temporaryCount:(int)temporaryCount
{
    if (mode == MSCountDownViewModeCountDown) {
        _count = temporaryCount;
        self.currentMode = mode;
    } else {
        self.currentMode = MSCountDownViewModeNormal;
    }
}

- (void)setCurrentMode:(MSCountDownViewMode)currentMode
{
    _currentMode = currentMode;
    self.userInteractionEnabled = currentMode == MSCountDownViewModeNormal ? YES : NO;
    if (currentMode == MSCountDownViewModeNormal) {
        [self invalidate];
        self.date = nil;
        _count = self.defaultCount;
        if (self.style == MSCountDownStyleNormal) {
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.lbTitle.textColor = RGB(153, 153, 153);
        }else if (self.style == MSCountDownStylePay) {
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [UIColor redColor].CGColor;
            self.lbTitle.textColor = RGB(233, 113, 116);
        }
        self.lbTitle.text = @"获取验证码";
    }else if (currentMode == MSCountDownViewModeIntermediate){
        
        if (self.style == MSCountDownStyleNormal) {
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.lbTitle.textColor = RGB(153, 153, 153);
        }else if (self.style == MSCountDownStylePay) {
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [UIColor redColor].CGColor;
            self.lbTitle.textColor = RGB(233, 113, 116);
        }
        self.lbTitle.text = @"获取中";
    }else if (currentMode == MSCountDownViewModeCountDown){
        
        if (self.style == MSCountDownStyleNormal) {
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.lbTitle.textColor = RGB(153, 153, 153);
        }else if (self.style == MSCountDownStylePay) {
            self.backgroundColor = RGB(237, 238, 239);
            self.layer.borderColor = RGB(237, 238, 239).CGColor;
            self.lbTitle.textColor = RGB(165, 166, 167);
        }
        self.lbTitle.text = [NSString stringWithFormat:@"%d秒后重发",_count];
        [self begin];
    }else{
        NSLog(@"currentMode 枚举值传值不对");
        self.currentMode = MSCountDownViewModeNormal;
    }
}

- (void)begin
{
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)enterBackground
{
    if (self.currentMode == MSCountDownViewModeCountDown) {
        self.date = [NSDate date];
    }
}

- (void)enterForeground
{
    if (self.currentMode == MSCountDownViewModeCountDown) {
        int interval = (int)ceil([[NSDate date] timeIntervalSinceDate:self.date]);
        int val = _count - interval;
        _count = val > 0 ? val : 0;
    }
}

- (void)countDown
{
    if (_count <= 1) {
        [self invalidate];
        self.currentMode = MSCountDownViewModeNormal;
        if (self.didEndCountdown) {
            self.didEndCountdown();
        }
    }else{
        _count -= 1;
        self.lbTitle.text = [NSString stringWithFormat:@"%d秒后重发",_count];
    }
}

- (void)willCountdown
{
    self.currentMode = MSCountDownViewModeIntermediate;
    if (self.willBeginCountdown) {
        self.willBeginCountdown();
    }else{
        self.currentMode = MSCountDownViewModeNormal;
    }
}

- (void)invalidate
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
     NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
