//
//  DataBindViewController.m
//  RAClearn
//
//  Created by lw on 2018/4/17.
//  Copyright © 2018年 mjsfax. All rights reserved.
//

#import "DataBindViewController.h"
#import "HotelTitleCell.h"
#import "HotelTitleViewModel.h"

@interface DataBindViewController ()
@property (strong, nonatomic) HotelTitleCell *cell;
@property (strong, nonatomic) HotelTitleViewModel *viewModel;
@end

@implementation DataBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cell = [[HotelTitleCell alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.cell];
    self.viewModel = [[HotelTitleViewModel alloc] init];
    [self.cell bindViewModel:self.viewModel];
    
}


@end
