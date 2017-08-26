//
//  ContractInfo.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "ContractInfo.h"
#import "MSUrlManager.h"

@implementation ContractInfo

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj {
    ContractInfo *contractInfo = [[ContractInfo alloc] init];
    contractInfo.contractName = [jsonObj objectForKey:@"name"];
    NSString *url = [jsonObj objectForKey:@"url"];
    if (url) {
        contractInfo.contractURL = [NSString stringWithFormat:@"%@%@", [MSUrlManager getImageUrlPrefix], url];
    }
    contractInfo.order = [[jsonObj objectForKey:@"order"] unsignedIntegerValue];
    return contractInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class ContractInfo { \n"];
    [sb appendFormat:@"  contractName: %@", self.contractName];
    [sb appendFormat:@"  contractURL: %@", self.contractURL];
    [sb appendFormat:@"  order: %lul", (unsigned long)self.order];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
