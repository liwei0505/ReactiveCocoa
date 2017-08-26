//
//  MSInsuranceTypeView.h
//  Sword
//
//  Created by lee on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InsuranceTypeSelected) {
    SelectedLeft,
    SelectedMiddle,
    SelectedRight,
};

@interface MSInsuranceTypeView : UIView
@property (copy, nonatomic) void(^selectBlock)(InsuranceTypeSelected type);
@property (strong, nonatomic) NSArray<InsuranceProduct *> *dataArray;
@end
