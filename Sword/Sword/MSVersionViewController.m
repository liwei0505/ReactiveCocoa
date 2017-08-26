//
//  MSVersionViewController.m
//  Sword
//
//  Created by msj on 2017/6/20.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSVersionViewController.h"
#import "UIView+FrameUtil.h"
#import "MSHomeFooterView.h"

typedef NS_ENUM(NSUInteger, MSVERSION) {
    PHONE,
    VERSION
};

@interface MSVersionView : UIView
- (void)updateWithTitle:(NSString *)title subTitle:(NSString *)subTitle type:(MSVERSION)type;
@property (copy, nonatomic) void (^block)(void);

@end

@interface MSVersionView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbSubTitle;
@end

@implementation MSVersionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = (self.width - 32)/2.0;
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, width, self.height)];
        [self addSubview:self.lbTitle];
        self.lbTitle.font = [UIFont systemFontOfSize:14];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        
        self.lbSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(16+width, 0, width, self.height)];
        [self addSubview:self.lbSubTitle];
        self.lbSubTitle.font = [UIFont systemFontOfSize:14];
        self.lbSubTitle.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title subTitle:(NSString *)subTitle type:(MSVERSION)type {
    if (type == PHONE) {
        self.lbSubTitle.textColor = [UIColor ms_colorWithHexString:@"#4229B3"];
    }else {
        self.lbSubTitle.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
    }
    self.lbTitle.text = title;
    self.lbSubTitle.text = subTitle;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor ms_colorWithHexString:@"#f0f0f0"];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor ms_colorWithHexString:@"#f0f0f0"];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor whiteColor];
    if (self.block) {
        self.block();
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor whiteColor];
}
@end

@interface MSVersionViewController ()

@end

@implementation MSVersionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureElement];
    [self addSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.navigationItem.title pageId:183 params:nil];
}

- (void)configureElement {
    self.navigationItem.title = @"当前版本";
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
}

- (void)addSubviews {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 104)/2.0, 41*scaleY, 104, 104)];
    imageView.image = [UIImage imageNamed:@"ms_version"];
    [self.view addSubview:imageView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+63*scaleY, self.view.width, 128)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    @weakify(self);
    
    MSVersionView *phone = [[MSVersionView alloc] initWithFrame:CGRectMake(0, 0, contentView.width, 64)];
    [phone updateWithTitle:@"客服电话" subTitle:@"400-001-1111" type:PHONE];
    [contentView addSubview:phone];
    phone.block = ^{
        @strongify(self);
        [self call];
    };
    
    MSVersionView *version = [[MSVersionView alloc] initWithFrame:CGRectMake(0, 64, contentView.width, 64)];
    [version updateWithTitle:@"当前版本" subTitle:[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"] type:VERSION];
    [contentView addSubview:version];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 63.5, contentView.width - 16, 1)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [contentView addSubview:line];
    
    MSHomeFooterView *footerView = [[MSHomeFooterView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64 - 40, self.view.width, 25)];
    footerView.tips = @"北京民金所金融信息服务有限公司";
    [self.view addSubview:footerView];
    
}

- (void)call {
    NSString *telNumber = @"400-001-1111";
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,2,0}]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",telNumber]]];
    } else {
        [MSAlert showWithTitle:telNumber message:nil buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",telNumber]]];
            }
        } cancelButtonTitle:NSLocalizedString(@"str_cancel", @"") otherButtonTitles:NSLocalizedString(@"str_call", @""), nil];
    }
}
@end
