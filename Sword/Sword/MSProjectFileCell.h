//
//  MSProjectFileCell.h
//  Sword
//
//  Created by msj on 16/9/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectInfo.h"

@interface MSProjectFileCell : UITableViewCell
+ (MSProjectFileCell *)cellWithTableView:(UITableView *)tableView;
- (void)updateContent:(ProductFileInfo *)fileInfo index:(NSInteger)index;
@end
