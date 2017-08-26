//
//  MSSectionList.h
//  Sword
//
//  Created by msj on 2017/4/1.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSSectionListType) {
    //活期
    MSSectionListTypeCurrent = 1,
    
    //定期
    MSSectionListTypeNewer = 2,
    MSSectionListTypeWillStart = 3,
    MSSectionListTypeInvesting = 4,
    MSSectionListTypeCompleted = 5,
    
    //保险
    MSSectionListTypeInsurance = 6
    
    //can add more type...
};

@interface MSSectionList : NSObject
@property (assign, nonatomic, readonly) MSSectionListType type;
@property (strong, nonatomic, readonly) MSListWrapper *listWrapper;

+ (MSSectionList *)sectionListWithType:(MSSectionListType)type listWrapper:(MSListWrapper *)listWrapper;

@end
