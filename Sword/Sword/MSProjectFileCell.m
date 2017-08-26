//
//  MSProjectFileCell.m
//  Sword
//
//  Created by msj on 16/9/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSProjectFileCell.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"

@interface MSProjectFileCell ()
@property (strong, nonatomic) UIImageView *imageIcon;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIImageView *imageArrow;
@property (strong, nonatomic) UIView *topLine;

@property (strong, nonatomic) ProductFileInfo *fileInfo;

@end

@implementation MSProjectFileCell

+ (MSProjectFileCell *)cellWithTableView:(UITableView *)tableView
{
    MSProjectFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSProjectFileCell"];
    if (!cell) {
        cell = [[MSProjectFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSProjectFileCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product_image"]];
        [self.contentView addSubview:self.imageIcon];
        
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.font = [UIFont systemFontOfSize:16];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbTitle];
        
        self.imageArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
        [self.contentView addSubview:self.imageArrow];
        
        self.topLine = [[UIView alloc] init];
        self.topLine.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
        [self.contentView addSubview:self.topLine];
        self.topLine.hidden = YES;
        
    }
    return self;
}

- (void)updateContent:(ProductFileInfo *)fileInfo index:(NSInteger)index
{
    _fileInfo = fileInfo;
    self.topLine.hidden = index ? NO : YES;
    self.lbTitle.text = fileInfo.fileName;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageIcon.frame = CGRectMake(16, (self.height - 16)/2.0, 16, 16);
    self.imageArrow.frame = CGRectMake(self.width - 21 - 12, (self.height - 12)/2.0, 12, 12);
    CGFloat width = self.imageArrow.x - (CGRectGetMaxX(self.imageIcon.frame) + 10) - 10;
    self.lbTitle.frame = CGRectMake(CGRectGetMaxX(self.imageIcon.frame) + 10, 0, width, self.height);
    self.topLine.frame = CGRectMake(0, 0, self.width, 1);
}

@end
