//
//  MSCurrentDetailBar.h
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSCurrentDetailBarType) {
    MSCurrentDetailBarTypeInvest = 1,
    MSCurrentDetailBarTypeRedeem
};

@interface MSCurrentDetailBar : UIView
- (void)updateWithAssetInfo:(AssetInfo *)assetInfo currentDetail:(CurrentDetail *)currentDetail;
@property (copy, nonatomic) void (^actionBlock)(MSCurrentDetailBarType type);
@end
