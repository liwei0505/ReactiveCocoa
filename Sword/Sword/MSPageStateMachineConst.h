//
//  MSPageStateMachineConst.h
//  showTime
//
//  Created by msj on 2017/5/15.
//  Copyright © 2017年 msj. All rights reserved.
//

#ifndef MSPageStateMachineConst_h
#define MSPageStateMachineConst_h

typedef NS_ENUM(NSInteger, MSPageStateMachineType) {
    MSPageStateMachineType_idle,
    MSPageStateMachineType_loading,
    MSPageStateMachineType_loaded,
    MSPageStateMachineType_empty,
    MSPageStateMachineType_error
};


#endif /* MSPageStateMachineConst_h */
