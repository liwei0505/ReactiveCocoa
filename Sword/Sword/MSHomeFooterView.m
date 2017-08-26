//
//  MSHomeFooterView.m
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSHomeFooterView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"

@interface MSHomeFooterView ()
@property (strong, nonatomic) UILabel *lbTips;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation MSHomeFooterView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        
        self.lbTips = [[UILabel alloc] init];
        self.lbTips.font = [UIFont systemFontOfSize:10];
        self.lbTips.textAlignment = NSTextAlignmentCenter;
        self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
        [self addSubview:self.lbTips];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"ms_shield"];
        [self addSubview:self.imageView];
        
        self.tips = @"迄今为止交易无风险，第三方担保";
    }
    return self;
}

- (void)setTips:(NSString *)tips {
    _tips = tips;
    
    self.lbTips.text = tips;
    
    CGSize size = [tips sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}];
    self.lbTips.frame = CGRectMake((self.width - size.width)/2.0, (self.height - size.height)/2.0, size.width, size.height);
    
    self.imageView.frame = CGRectMake(self.lbTips.x - 15, (self.height - 12)/2.0, 12, 12);
}
@end
