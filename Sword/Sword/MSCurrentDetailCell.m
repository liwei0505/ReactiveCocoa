//
//  MSCurrentDetailCell.m
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentDetailCell.h"

@interface MSCurrentDetailCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@end

@implementation MSCurrentDetailCell
+ (MSCurrentDetailCell *)cellWithTableView:(UITableView *)tableView
{
    MSCurrentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSCurrentDetailCell"];
    if (!cell) {
        cell = [[MSCurrentDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSCurrentDetailCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        UIImageView *arrowImageView = [UIImageView newAutoLayoutView];
//        arrowImageView.image = [UIImage imageNamed:@"right_arrow"];
//        [self.contentView addSubview:arrowImageView];
//        [arrowImageView autoSetDimensionsToSize:CGSizeMake(8, 14)];
//        [arrowImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
//        [arrowImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont systemFontOfSize:13];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    return self;
}

- (void)setProductItem:(CurrentProductItem *)productItem {
    _productItem = productItem;
    self.lbTitle.text = [NSString stringWithFormat:@"《%@》",productItem.name];
}
@end
