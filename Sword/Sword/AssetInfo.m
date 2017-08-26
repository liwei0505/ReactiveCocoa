//
//  AssetInfo.m
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "AssetInfo.h"

@implementation AssetInfo

- (instancetype)init {
    if (self = [super init]) {
        _regularAsset = [[RegularAsset alloc] init];
        _currentAsset = [[CurrentAsset alloc] init];
    }
    return self;
}

- (NSDecimalNumber *)totalAmount {
    NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:@"0"];
    if (self.balance) {
        totalAmount = [totalAmount decimalNumberByAdding:self.balance];
    }
    return [[totalAmount decimalNumberByAdding:self.regularAsset.totalAmount] decimalNumberByAdding:self.currentAsset.totalAmount];
}

@end

@implementation RegularAsset

- (NSDecimalNumber *)totalAmount {
    NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:@"0"];
    if (self.tobeReceivedPrincipal) {
        totalAmount = [totalAmount decimalNumberByAdding:self.tobeReceivedPrincipal];
    }
    if (self.tobeReceivedInterest) {
        totalAmount = [totalAmount decimalNumberByAdding:self.tobeReceivedInterest];
    }
    if (self.investFrozenAmount) {
        totalAmount = [totalAmount decimalNumberByAdding:self.investFrozenAmount];
    }
    return totalAmount;
}

@end

@implementation CurrentAsset

- (NSDecimalNumber *)totalAmount {
    NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:@"0"];
    if (self.investAmount) {
        totalAmount = [totalAmount decimalNumberByAdding:self.investAmount];
    }
    if (self.addUpAmount) {
        totalAmount = [totalAmount decimalNumberByAdding:self.addUpAmount];
    }
    if (self.purchaseFrozenAmount) {
        totalAmount = [totalAmount decimalNumberByAdding:self.purchaseFrozenAmount];
    }
    return totalAmount;
}

- (NSDecimalNumber *)canRedeemAmount {
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"0"];
    if (self.investAmount) {
        amount = [amount decimalNumberByAdding:self.investAmount];
    }
    if (self.addUpAmount) {
        amount = [amount decimalNumberByAdding:self.addUpAmount];
    }
    return amount;
}

@end
