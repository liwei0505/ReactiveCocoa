//
//  MSAccountCell.h
//  Sword
//
//  Created by lee on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSAccountModel.h"

@interface MSAccountCell : UICollectionViewCell
@property (strong, nonatomic) MSAccountModel *model;
@property (copy, nonatomic) void (^block)(void);
@end
