//
//  MSInviteView.m
//  Sword
//
//  Created by msj on 2017/3/28.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInviteView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "UIImage+color.h"
#import "MSShareManager.h"
#import "MSShareModel.h"
#import "MSInviteButton.h"
#import "MSQRCodeGenerator.h"
#import "RACEmptySubscriber.h"

@interface MSInviteView ()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTips;

@property (strong, nonatomic) NSMutableArray *shareArray;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *shareUrl;
@property (copy, nonatomic) NSString *iconUrl;
@property (copy, nonatomic) NSString *shareId;
@end

@implementation MSInviteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubViews];
        [self addNotifications];
    }
    return self;
}

- (void)addSubViews {
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(38, 130, [UIScreen mainScreen].bounds.size.width - 76, 0)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.alpha = 0;
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    [self addSubview:self.contentView];
    
    self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, self.contentView.width, 14)];
    self.lbTitle.font = [UIFont systemFontOfSize:14];
    self.lbTitle.text = @"扫一扫";
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#5C5C5C"];
    self.lbTitle.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.lbTitle];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.lbTitle.frame) + 12, self.contentView.width - 100, self.contentView.width - 100)];
    self.imageView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.imageView.layer.shadowRadius = 1;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOpacity = 0.3;
    [self.contentView addSubview:self.imageView];
    
    self.lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 21, self.contentView.width, 14)];
    self.lbTips.font = [UIFont systemFontOfSize:14];
    self.lbTips.text = @"其他分享方式";
    self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#5C5C5C"];
    self.lbTips.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.lbTips];
    
    self.shareArray = [NSMutableArray array];
    MSShareModel *wxq = [[MSShareModel alloc] initWithTitle:@"朋友圈" withIcon:@"shareWechatCircleIcon" withShareType:share_wx_pyq];
    MSShareModel *wxf = [[MSShareModel alloc] initWithTitle:@"微信" withIcon:@"shareWechatIcon" withShareType:share_wx_hy];
    MSShareModel *qqf = [[MSShareModel alloc] initWithTitle:@"QQ" withIcon:@"shareQQIcon" withShareType:share_qq_hy];
    MSShareModel *sina = [[MSShareModel alloc] initWithTitle:@"微博" withIcon:@"shareSinaIcon" withShareType:share_wb];
    MSShareModel *web = [[MSShareModel alloc] initWithTitle:@"浏览器" withIcon:@"shareWebIcon" withShareType:share_browse];
    
    if ([WeiboSDK isWeiboAppInstalled]) {
        [self.shareArray addObject:sina];
    }
    
    if ([WXApi isWXAppInstalled]) {
        [self.shareArray addObject:wxf];
        [self.shareArray addObject:wxq];
    }
    
    if([QQApiInterface isQQInstalled]){
        [self.shareArray addObject:qqf];
    }
    
    if (self.shareArray.count == 0) {
        [self.shareArray addObject:web];
    }
    
    CGFloat width = self.contentView.width / 4.0;
    CGFloat height = width;
    CGFloat y = CGRectGetMaxY(self.lbTips.frame) + 10;
    for (int i = 0; i < self.shareArray.count; i++) {
        MSShareModel *shareModel = self.shareArray[i];
        CGFloat x = i * width;
        MSInviteButton *btn = [[MSInviteButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        btn.shareModel = shareModel;
        [self.contentView addSubview:btn];
        @weakify(self);
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self shareAction:btn.shareModel];
        }];
    }
    self.contentView.height = y + height + 20;
    
    @weakify(self);
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((self.width - 35)/2.0, CGRectGetMaxY(self.contentView.frame)+24, 35, 35)];
    [btn setImage:[UIImage imageNamed:@"ms_share_btn_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ms_share_btn_highlight"] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self removeFromSuperview];
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap.rac_gestureSignal subscribeNext:^(UITapGestureRecognizer *tap) {
        @strongify(self);
        CGPoint point = [tap locationInView:tap.view];
        if (!CGRectContainsPoint(self.contentView.frame, point)) {
            [self removeFromSuperview];
        }
    }];
    [self addGestureRecognizer:tap];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancel) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)cancel
{
    [self removeFromSuperview];
}
- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        return;
    }
    
    self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
}
- (void)removeFromSuperview
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

-(void)shareCanceled:(UIButton *)cancelBtn
{
    [self removeFromSuperview];
}

-(void)setShareUrl:(NSString *)shareUrl shareTitle:(NSString *)title shareContent:(NSString *)content shareIcon:(NSString *)iconUrl shareId:(NSString *)shareId
{
    self.title = title;
    self.content = content;
    self.iconUrl = iconUrl;
    self.shareUrl = shareUrl;
    self.shareId = shareId;
    
    NSURL *imageUrl = [NSURL URLWithString:self.iconUrl];
    if ([imageUrl.scheme isEqualToString:@"https"]) {
        self.iconUrl = [self.iconUrl stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
    }
    
    self.imageView.image = [MSQRCodeGenerator ms_creatQRCodeWithMessage:self.shareUrl];
    
    NSLog(@"title==%@",title);
    NSLog(@"content==%@",content);
    NSLog(@"shareId==%@",shareId);
    NSLog(@"iconUrl==%@",iconUrl);
    NSLog(@"shareUrl==%@",shareUrl);
}

#pragma mark - Action
- (void)shareAction:(MSShareModel *)shareModel
{
    switch (shareModel.shareType) {
        case share_wx_pyq:
        {
            [self sendWxReqWithScene:WXSceneTimeline];
        }
            break;
        case share_wx_hy:
        {
            [self sendWxReqWithScene:WXSceneSession];
        }
            break;
        case share_qq_zone:
        {
            [self sendQQReqWithShareType:share_qq_zone];
        }
            break;
        case share_qq_hy:
        {
            [self sendQQReqWithShareType:share_qq_hy];
        }
            
            break;
        case share_wb:
        {
            [self sendWeiBoReq];
            
        }
            break;
        case share_browse:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.shareUrl]];
        }
            break;
            
        default:
            break;
    }
    if (self.selectedShareType) {
        self.selectedShareType(shareModel.title);
    }
}

- (void)sendWxReqWithScene:(int)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.title;
    message.description = self.content;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.shareUrl;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_SHARE";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    UIImage *cachedImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.iconUrl];
    if(!cachedImg){
        [MSToast show:@"加载分享图片"];
       
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.iconUrl]
                                                    options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                        
                                                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                        UIImage *shareImage = (image ? image : [UIImage imageNamed:@"share_placeholder"]);
                                                        NSData *imageData = UIImageJPEGRepresentation(shareImage, 1.0);
                                                        float imageSize = (float)imageData.length/1024.0;
                                                        if (imageSize>=32) {
                                                            shareImage = [UIImage ms_scaleToSize:shareImage ratio:32/(imageSize+10)];
                                                        }
                                                        
                                                        [message setThumbImage:shareImage];
                                                        [WXApi sendReq:req];
                                                    }];
    }else{
        NSData *imageData = UIImageJPEGRepresentation(cachedImg, 1.0);
        float imageSize = (float)imageData.length/1024.0;
        if (imageSize>=32) {
            cachedImg = [UIImage ms_scaleToSize:cachedImg ratio:32/(imageSize+10)];
        }
        
        [message setThumbImage:cachedImg];
        [WXApi sendReq:req];
    }
}

- (void)sendQQReqWithShareType:(MSShareType)type
{
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:self.shareUrl]
                                title:self.title
                                description:self.content
                                previewImageURL:[NSURL URLWithString:self.iconUrl] targetContentType:QQApiURLTargetTypeNews];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    if (type == share_qq_zone) {
        [QQApiInterface SendReqToQZone:req];
    }else if(type == share_qq_hy){
        [QQApiInterface sendReq:req];
    }
}

- (void)sendWeiBoReq
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = @"http://www.sharesdk.cn";
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = self.shareId;
    webpage.title = self.title;
    webpage.description = self.content;
    webpage.webpageUrl = self.shareUrl;
    message.mediaObject = webpage;
    message.text = self.content;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:[MSShareManager sharedManager].wbApiResponse.sinaAccessToken];
    
    UIImage *cachedImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.iconUrl];
    if(!cachedImg){
        [MSToast show:@"加载分享图片"];
      
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.iconUrl]
                                                    options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                        
                                                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                        UIImage *shareImage = (image ? image : [UIImage imageNamed:@"share_placeholder"]);
                                                        NSData *imageData = UIImageJPEGRepresentation(shareImage, 1.0);
                                                        float imageSize = (float)imageData.length/1024.0;
                                                        if (imageSize >= 32) {
                                                            shareImage = [UIImage ms_scaleToSize:shareImage ratio:32/(imageSize+10)];
                                                        }
                                                        imageData = UIImageJPEGRepresentation(shareImage, 1.0);
                                                        webpage.thumbnailData = imageData;
                                                        [WeiboSDK sendRequest:request];
                                                    }];
    }else{
        NSData *imageData = UIImageJPEGRepresentation(cachedImg, 1.0);
        float imageSize = (float)imageData.length/1024.0;
        if (imageSize >= 32) {
            cachedImg = [UIImage ms_scaleToSize:cachedImg ratio:32/(imageSize+10)];
        }
        imageData = UIImageJPEGRepresentation(cachedImg, 1.0);
        webpage.thumbnailData = imageData;
        [WeiboSDK sendRequest:request];
    }
}

- (void)dealloc
{
    [self removeNotifications];
    NSLog(@"%s",__func__);
}

@end
