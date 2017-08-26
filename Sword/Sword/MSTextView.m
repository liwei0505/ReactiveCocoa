//
//  MSTextView.m
//  feedback
//
//  Created by lee on 2017/5/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSTextView.h"
#import "UIColor+StringColor.h"
#import "NSString+Ext.h"

@interface MSTextView()<UITextViewDelegate>
@property (strong, nonatomic) UILabel *lbPlaceHolder;
@property (assign, nonatomic) NSUInteger replaceStringLength;
@end

@implementation MSTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        _lbPlaceHolder = [[UILabel alloc] init];
        _lbPlaceHolder.font = [UIFont systemFontOfSize:14];
        _lbPlaceHolder.textColor = [UIColor ms_colorWithHexString:@"CCCCCC"];
        _lbPlaceHolder.numberOfLines = 0;
        [self addSubview:_lbPlaceHolder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
        self.returnKeyType = UIReturnKeyDone;
        self.delegate = self;
    }
    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:UITextViewTextDidChangeNotification];
}

- (void)textDidChange {
    
    self.lbPlaceHolder.hidden = self.hasText;
    
}

- (void)layoutSubviews {

    [super layoutSubviews];
    float width = self.bounds.size.width-6*2;
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    float height =  [self.placeholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lbPlaceHolder.font} context:nil].size.height;
    self.lbPlaceHolder.frame = CGRectMake(6, 6, width, height);
}

- (void)setPlaceholder:(NSString *)placeholder {

    _placeholder = placeholder;
    self.lbPlaceHolder.text = placeholder;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {

    [super setText:text];
    [self textDidChange];
    
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self textDidChange];
}

#pragma mark - delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if (![NSString stringCommentCheck:textView.text] && ![textView.text isEqualToString:@""]) {
        
        NSString *text = textView.text;
        textView.text = [text substringToIndex:text.length-self.replaceStringLength];
    }
    
    if (textView.text.length >= 200) {
        textView.text = [textView.text substringToIndex:200];
    }
    if (self.textCountBlock) {
        self.textCountBlock(textView.text.length);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [self endEditing:YES];
        return YES;
    }
    
    self.replaceStringLength = text.length;
    return YES;
}
@end
