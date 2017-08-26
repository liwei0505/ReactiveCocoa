//
//  MSPolicyDetailViewModel.h
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSPolicyDetailViewModel : NSObject
@property (strong, nonatomic, readonly) NSMutableArray *datas;
@property (strong, nonatomic) InsurancePolicy *policy;
@end
