//
//  MSTrendChartView.h
//  showTime
//
//  Created by msj on 2017/3/20.
//  Copyright © 2017年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTrendChartView : UIView
- (void)updateWithMinTrend:(NSNumber *)minTrend maxTrend:(NSNumber *)maxTrend lineCount:(NSInteger)lineCount brokenLineColor:(UIColor *)brokenLineColor times:(NSArray *)times points:(NSArray *)points mask:(BOOL)mask animation:(BOOL)animation;
@end
