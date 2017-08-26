//
//  MSInviteFriendCell.h
//  Sword
//
//  Created by lee on 16/7/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendInfo.h"

@interface MSInviteFriendCell : UITableViewCell
+ (MSInviteFriendCell *)cellWithTableView:(UITableView *)tableView;
- (void)updateWithFriendInfo:(FriendInfo *)friendInfo index:(NSInteger)index;
@end
