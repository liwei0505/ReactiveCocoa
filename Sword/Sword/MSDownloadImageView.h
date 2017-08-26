//
//  MSDownloadImageView.h
//  Sword
//
//  Created by lee on 2017/8/26.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSDownloadImageView : UIImageView
@property (assign, nonatomic) int imageTag;
- (void)loadImageWithURL:(NSString *)url completion:(void(^)(int tag, UIImage *image))completion;
@end
