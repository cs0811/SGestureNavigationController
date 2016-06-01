//
//  BaseVC.m
//  SGestureNavigationController
//
//  Created by dufei on 16/6/1.
//  Copyright © 2016年 dufei. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.s_interactivePopDisabled = YES;
    self.s_interactivePopMaxAllowedInitialDistanceToLeftEdge = CGRectGetWidth(self.view.bounds)/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
