//
//  ViewController.m
//  ImageDown
//
//  Created by 廖磊 on 2017/10/17.
//  Copyright © 2017年 东边的风. All rights reserved.
//

#import "ViewController.h"
#import "PicShowGraduallyViewController.h"
/**
 *本地gif图片path
 */
#define imgURL [[NSBundle mainBundle]pathForResource:@"54D2FBAC25E9A188F0BAD11F1401BCA4" ofType:@"gif"]
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 300, 100, 50);
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

-(void)btnClick:(UIButton *)btn{
    PicShowGraduallyViewController *ctl = [[PicShowGraduallyViewController alloc]init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
