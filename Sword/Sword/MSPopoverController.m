//
//  MSPopoverController.m
//  Sword
//
//  Created by lee on 2017/8/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPopoverController.h"

@interface MSPopoverController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation MSPopoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepare];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)prepare {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.dataArray = [[NSMutableArray alloc] initWithObjects:@"父母",@"子女", @"配偶",@"其他", nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedBlock) {
        self.selectedBlock(indexPath.row+2);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGSize)preferredContentSize {
    
    if (self.presentingViewController && self.tableView != nil) {
        CGSize tempSize = self.presentingViewController.view.bounds.size;
        tempSize.width = 150;
        CGSize size = [self.tableView sizeThatFits:tempSize];
        return size;
    }else {
        return [super preferredContentSize];
    }
    
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize {
    super.preferredContentSize = preferredContentSize;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}



@end
