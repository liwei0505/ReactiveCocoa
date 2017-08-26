//
//  MSCurrentDetailHeaderView.h
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSCurrentDetailHeaderView : UIView
- (void)updateWithAssetInfo:(AssetInfo *)assetInfo currentInfo:(CurrentInfo *)currentInfo currentDetail:(CurrentDetail *)currentDetail;
@end
