//
//  MSRiskCollectionView.m
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskCollectionView.h"
#import "RiskInfo.h"
#import "MSRiskTopicViewController.h"
#import "UIView+viewController.h"

@implementation MSRiskCollectionView

#pragma mark - UIGestureRecognizerDelegate

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.panGestureRecognizer.minimumNumberOfTouches = 1;
        self.panGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
//    NSLog(@"tracking====%d===dragging====%d====decelerating===%d",self.tracking,self.dragging,self.decelerating);
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer velocityInView:self];
        if (point.x > 0) {
            return YES;
        }else{
            NSIndexPath *indexpath = self.indexPathsForVisibleItems.firstObject;
            MSRiskTopicViewController *vc = (MSRiskTopicViewController *)self.ms_viewController;
            RiskInfo *riskInfo = vc.dataArr[indexpath.item];
            if (riskInfo.isCompeleted) {
                if (self.dragging && self.decelerating) {
                    return NO;
                }else{
                    return YES;
                }
            }else{
                return NO;
            }
        }
        
    }
    return YES;
}
@end
