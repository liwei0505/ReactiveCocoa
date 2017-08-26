//
//  MSFormFile.h
//  Sword
//
//  Created by haorenjie on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFormInfo.h"

@interface MSFormFile : MSFormInfo

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *mime;

@end
