//
//  MSSectionList.m
//  Sword
//
//  Created by msj on 2017/4/1.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSSectionList.h"

@interface MSSectionList ()
@property (assign, nonatomic, readwrite) MSSectionListType type;
@property (strong, nonatomic, readwrite) MSListWrapper *listWrapper;
@end

@implementation MSSectionList
+ (MSSectionList *)sectionListWithType:(MSSectionListType)type listWrapper:(MSListWrapper *)listWrapper {
    MSSectionList *list = [[MSSectionList alloc] init];
    list.type = type;
    list.listWrapper = listWrapper;
    return list;
}
@end
