//
//  MSInsuranceScrollView.m
//  Sword
//
//  Created by lee on 2017/8/26.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceScrollView.h"
#import "MSDownloadImageView.h"

@interface MSInsuranceScrollView()

@property (strong, nonatomic) UIView *contentView;

@end

@implementation MSInsuranceScrollView

//- (void)layoutSubviews {
//    
//    [super layoutSubviews];
//    
//    if (!self.imageDict.count) {
//        return;
//    }
//    
//    float lastBottom = 0;
//    float lastItem = 0;
//    
//    for (int i=1; i<=self.imageDict.count; i++) {
//        
//        NSArray *array = [self.imageDict objectForKey:@(i)];
//        
//        for (int j=0; j<array.count; j++) {
//            id obj = [self.subviews objectAtIndex:j+lastItem];
//            if (![obj isKindOfClass:[MSDownloadImageView class]]) {
//                continue;
//            }
//            
//            MSDownloadImageView *imageView = (MSDownloadImageView *)obj;
//            imageView.y += lastBottom;
//            lastBottom = CGRectGetMaxY(imageView.frame);
//            
//            if (j==(array.count-1)) {
//                float max = CGRectGetMaxY(imageView.frame);
//                self.contentSize = CGSizeMake(0, max);
//                self.viewModel.scrollHeightArray[i] = [NSNumber numberWithFloat:max];
//            }
//        }
//        lastItem += array.count;
//    }
//    
//}

- (instancetype)init {
    if (self = [super init]) {
//        [self setup];
    }
    return self;
}

- (void)setup {
    self.contentView = [UIView newAutoLayoutView];
    [self addSubview:self.contentView];
    [self.contentView autoPinEdgesToSuperviewEdges];
    self.contentView.backgroundColor = [UIColor redColor];
}

- (void)setupSubviews {

 
    
}

- (void)setImageDict:(NSDictionary *)imageDict {
    _imageDict = imageDict;
    if (!imageDict.count) {
        return;
    }
    
}



@end
