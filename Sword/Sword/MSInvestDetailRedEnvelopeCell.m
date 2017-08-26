//
//  MSInvestDetailRedEnvelopeCell.m
//  Sword
//
//  Created by msj on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestDetailRedEnvelopeCell.h"

@interface MSInvestDetailRedEnvelopeCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@end

@implementation MSInvestDetailRedEnvelopeCell
+ (MSInvestDetailRedEnvelopeCell *)cellWithTableView:(UITableView *)tableView {
    MSInvestDetailRedEnvelopeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSInvestDetailRedEnvelopeCell"];
    if (!cell) {
        cell = [[MSInvestDetailRedEnvelopeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSInvestDetailRedEnvelopeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont systemFontOfSize:14];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
        [self.contentView addSubview:line];
        [line autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [line autoSetDimension:ALDimensionHeight toSize:0.5];
    }
    return self;
}

- (void)setRedEnvelope:(RedEnvelope *)redEnvelope {
    _redEnvelope = redEnvelope;
    self.lbTitle.text = redEnvelope.usageRange;
}
@end
