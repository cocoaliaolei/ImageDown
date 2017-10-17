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
    
    /**
     * 使用webview加载gif动态图
     */
    NSData *data = [NSData dataWithContentsOfFile:imgURL];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    webView.userInteractionEnabled = NO;
    [webView loadData:data MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.view addSubview:webView];
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    PicShowGraduallyViewController *ctl = [[PicShowGraduallyViewController alloc]init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
