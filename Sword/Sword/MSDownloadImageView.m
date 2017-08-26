//
//  MSDownloadImageView.m
//  Sword
//
//  Created by lee on 2017/8/26.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSDownloadImageView.h"
#import "UIImage+color.h"

@implementation MSDownloadImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)loadImageWithURL:(NSString *)url completion:(void(^)(int tag, UIImage *image))completion {
    @weakify(self);
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        @strongify(self);
        if (image) {
            float height = [UIScreen mainScreen].bounds.size.width * image.size.height / image.size.width * 1.0;
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height);
            self.image = image;
            completion(self.imageTag, image);
        }
        
    }];
}

@end
