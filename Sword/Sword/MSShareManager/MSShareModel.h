//
//  MSShareModel.h
//  Sword
//
//  Created by msj on 16/10/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    share_wx_pyq,
    share_wx_hy,
    share_qq_zone,
    share_qq_hy,
    share_wb,
    share_browse
}MSShareType;

@interface MSShareModel : NSObject
@property(nonatomic, copy, readonly) NSString *title;
@property(nonatomic, copy, readonly) NSString *icon;
@property(nonatomic, assign, readonly) MSShareType shareType;
-(instancetype)initWithTitle:(NSString *)title withIcon:(NSString *)icon withShareType:(MSShareType)shareType;
@end
