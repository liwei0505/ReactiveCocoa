//
//  MSInsuranceDetailViewModel.h
//  Sword
//
//  Created by lee on 2017/8/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSInsuranceDetailViewModel : NSObject
@property (assign, nonatomic) BOOL switchStatus;
@property (strong, nonatomic) InsuranceDetail *detail;
@property (copy, nonatomic) NSString *productId;
@property (assign, nonatomic) NSTimeInterval effectiveDate;
@property (assign, nonatomic) NSUInteger count;
@property (copy, nonatomic) NSString *mail;
@property (strong, nonatomic) InsurantInfo *info;
@property (strong, nonatomic) NSString *orderId;
@property (assign, nonatomic) BOOL typeOther;

#pragma mark - view
@property (strong, nonatomic) NSMutableArray *scrollHeightArray;

- (void)queryDetail:(NSString *)insuranceId completion:(void(^)(BOOL status))completion;
- (void)queryContentCompletion:(void(^)(BOOL status, NSDictionary *dict))completion;
- (void)insuranceCompletion:(void(^)(BOOL status, NSString *url))completion;

@end
