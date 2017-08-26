//
//  MSProjectFileController.h
//  Sword
//
//  Created by msj on 16/9/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "ProjectInfo.h"

@interface MSProjectFileController : MSBaseViewController
- (void)updateWithFileName:(NSString *)fileName fileUrl:(NSString *)fileUrl;
@end
