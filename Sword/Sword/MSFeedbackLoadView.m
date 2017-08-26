//
//  MSFeedbackLoadView.m
//  Sword
//
//  Created by lee on 2017/6/22.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFeedbackLoadView.h"

@interface MSFeedbackLoadView()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation MSFeedbackLoadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake((frame.size.width-30)*0.5, 20, 30, 30);
        imageView.layer.masksToBounds = YES;
        self.imageView = imageView;
        [self addSubview:self.imageView];
        
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+15, frame.size.width, 30)];
        lbTitle.textAlignment = NSTextAlignmentCenter;
        lbTitle.numberOfLines = 0;
        lbTitle.font = [UIFont systemFontOfSize:14];
        lbTitle.textColor = [UIColor ms_colorWithHexString:@"4a4a4a"];
        self.lbTitle = lbTitle;
        [self addSubview:self.lbTitle];
        
    }
    return self;
}

- (void)updateTitle:(NSString *)title load:(BOOL)load {

    self.lbTitle.text = title;
    if (load) {
        self.imageView.image = [UIImage imageNamed:@"pay_loading"];
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        ani.fromValue = @0;
        ani.toValue = @(2 * M_PI);
        ani.duration = 0.6;
        ani.fillMode = kCAFillModeForwards;
        ani.removedOnCompletion = NO;
        ani.repeatCount = MAXFLOAT;
        [self.imageView.layer addAnimation:ani forKey:@"feedback"];
    } else {
        [self.imageView.layer removeAnimationForKey:@"feedback"];
        self.imageView.image = [UIImage imageNamed:@"pay_success"];
    }
}

@end
