//
//  KVOController.m
//  RAClearn
//
//  Created by lee on 17/2/17.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "KVOController.h"
#import "StockData.h"

@interface KVOController ()

@property (strong, nonatomic) StockData *stockData;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;

@end

@implementation KVOController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self kvoTest];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor redColor];
    label.center = self.view.center;
    label.text = [self.stockData valueForKey:@"price"];
    [label sizeToFit];
    self.label = label;
    [self.view addSubview:self.label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 80, 40)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"button" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    self.button = button;
    [self.view addSubview:self.button];
    
    
}

- (void)click {
    
    [self.stockData setValue:@"20" forKey:@"price"];
}

//1. 注册，指定被观察者的属性，
//2. 实现回调方法
//3. 移除观察

- (void)kvoTest {

    self.stockData = [[StockData alloc] init];
    [self.stockData setValue:@"searph" forKey:@"stockName"];
    [self.stockData setValue:@"10.0" forKey:@"price"];
    //添加观察
    [self.stockData addObserver:self forKeyPath:@"price" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
}

//回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"price"]) {
        self.label.text = [self.stockData valueForKey:@"price"];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//移除观察者
- (void)dealloc {

    [_stockData removeObserver:self forKeyPath:@"price"];

}

@end
