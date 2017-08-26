//
//  MSShareView.m
//  Sword
//
//  Created by msj on 16/10/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSShareView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "UIImage+color.h"
#import "MSShareManager.h"
#import "MSShareModel.h"
#import "MSShareButtton.h"
#import "RACEmptySubscriber.h"

@interface MSShareView ()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray *shareArray;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *shareUrl;
@property (copy, nonatomic) NSString *iconUrl;
@property (copy, nonatomic) NSString *shareId;

@end

@implementation MSShareView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubVeiws];
        [self addNotifications];
    }
    return self;
}

- (void)addSubVeiws {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    self.shareArray = [NSMutableArray array];
    
    MSShareModel *wxq = [[MSShareModel alloc] initWithTitle:@"微信朋友圈" withIcon:@"shareWechatCircleIcon" withShareType:share_wx_pyq];
    MSShareModel *wxf = [[MSShareModel alloc] initWithTitle:@"微信好友" withIcon:@"shareWechatIcon" withShareType:share_wx_hy];
    MSShareModel *qqz = [[MSShareModel alloc] initWithTitle:@"QQ空间" withIcon:@"shareQQZoneIcon" withShareType:share_qq_zone];
    MSShareModel *qqf = [[MSShareModel alloc] initWithTitle:@"QQ好友" withIcon:@"shareQQIcon" withShareType:share_qq_hy];
    MSShareModel *sina = [[MSShareModel alloc] initWithTitle:@"新浪微博" withIcon:@"shareSinaIcon" withShareType:share_wb];
    MSShareModel *web = [[MSShareModel alloc] initWithTitle:@"浏览器" withIcon:@"shareWebIcon" withShareType:share_browse];
    
    if ([WXApi isWXAppInstalled]) {
        [self.shareArray addObject:wxq];
        [self.shareArray addObject:wxf];
    }
    
    if([QQApiInterface isQQInstalled]){
        [self.shareArray addObject:qqz];
        [self.shareArray addObject:qqf];
    }
    
    if ([WeiboSDK isWeiboAppInstalled]) {
        [self.shareArray addObject:sina];
    }
    
    [self.shareArray addObject:web];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 3.0;
    CGFloat height = 100;
    for (int i = 0; i < self.shareArray.count; i++) {
        MSShareModel *shareModel = self.shareArray[i];
        CGFloat x = (i % 3) * width;
        CGFloat y = (i / 3) * height;
        MSShareButtton *btn = [[MSShareButtton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        btn.shareModel = shareModel;
        [self.contentView addSubview:btn];
        @weakify(self);
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self shareAction:btn.shareModel.shareType];
        }];
    }
    
    UIView *spView = [[UIView alloc] initWithFrame:CGRectMake(0, ceil(self.shareArray.count/3.0)*100+10, [UIScreen mainScreen].bounds.size.width, 1)];
    spView.backgroundColor = [UIColor ms_colorWithHexString:@"#e3e3e3"];
    [self.contentView addSubview:spView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(spView.frame), [UIScreen mainScreen].bounds.size.width, 43);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor ms_colorWithHexString:@"#777777"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    [cancelBtn addTarget:self action:@selector(shareCanceled:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelBtn];
    
    self.contentView.height = CGRectGetMaxY(cancelBtn.frame);
    
    @weakify(self);
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
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.contentView.y = [UIScreen mainScreen].bounds.size.height - self.contentView.height;
    }];
    
}
- (void)removeFromSuperview
{
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.contentView.y = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
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
    
    NSLog(@"title==%@",title);
    NSLog(@"content==%@",content);
    NSLog(@"shareId==%@",shareId);
    NSLog(@"iconUrl==%@",iconUrl);
    NSLog(@"shareUrl==%@",shareUrl);
}

-(void)shareCanceled:(UIButton *)cancelBtn
{
    [self removeFromSuperview];
}

#pragma mark - Action
- (void)shareAction:(MSShareType)shareType
{
    switch (shareType) {
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
        
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.iconUrl] options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {}completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                       
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
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
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
