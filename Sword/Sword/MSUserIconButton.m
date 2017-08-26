//
//  MSUserIconButton.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSUserIconButton.h"
#import "UIView+FrameUtil.h"

@implementation MSUserIconButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userIcon = [[UIImageView alloc] init];
        [self addSubview:self.userIcon];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.userIcon.hidden = !selected;
    if (self.tag == 1) {
        self.userIcon.image = [UIImage imageNamed:@"user_default"];
        self.userIcon.frame = CGRectMake(self.height - 28, self.width - 32, 40, 24);
    } else {
        self.userIcon.image = [UIImage imageNamed:@"user_selected"];
        self.userIcon.frame = CGRectMake(self.height - 28, self.width - 28, 24, 24);
    }
}

@end
