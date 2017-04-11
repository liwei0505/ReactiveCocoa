//
//  ViewController.m
//  RAClearn
//
//  Created by lee on 17/2/17.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Caculator.h"
#import "Caculator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cacu];
}

//函数式编程
- (void)cacu {

    Caculator *c = [[Caculator alloc] init];
    BOOL isequle = [[[c caculator:^int(int a) {
        a += 2;
        a *= 5;
        return a;
    }] equle:^BOOL(int b) {
        return b == 10;
    }] isEqule];
    
    NSLog(@"%d",isequle);
}

//链式编程
- (void)caculate {

    int a = [NSObject makeCaculators:^(CaculatorMaker *make) {
        make.add(1);
    }];
    
    NSLog(@"%d",a);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
