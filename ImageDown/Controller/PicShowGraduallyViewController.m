//
//  PicShowGraduallyViewController.m
//  Category
//
//  Created by 廖磊 on 2017/10/11.
//  Copyright © 2017年 廖磊. All rights reserved.
//

#import "PicShowGraduallyViewController.h"
#import "LLImageLoadBit.h"

/**
 *网络静态图url
 */
//#define imgURL @"http://b.zol-img.com.cn/desk/bizhi/image/1/1920x1200/1348810232493.jpg"

/**
 * 网络gif图片URL
 */
//#define imgURL @"http://c.hiphotos.baidu.com/image/pic/item/d62a6059252dd42a6a943c180b3b5bb5c8eab8e7.jpg"


/**
 *本地gif图片path
 */
#define imgURL [[NSBundle mainBundle]pathForResource:@"54D2FBAC25E9A188F0BAD11F1401BCA4" ofType:@"gif"]


@interface PicShowGraduallyViewController ()<LLImageLoadBitDelegate>

@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation PicShowGraduallyViewController

-(void)dealloc{
    
    NSLog(@"------------:%s",__FUNCTION__);
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initView];
    
}

-(void)initView{
    
    [self.view addSubview:self.imgView];
    
    /**
     * block模式
     */
    [[LLImageLoadBit alloc]initWithUrl:imgURL withType:gifImages  withBlock:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgView.image = image;
        });
    }];
    
    /**
     * 代理模式
     */
    
//    [[LLImageLoadBit alloc]initWithUrl:imgURL withDelegate:self withType:gifImages];
    
}

-(void)LLImageLoadBitDiddidReceiveGetImages:(UIImage *)image{
    
    dispatch_async(dispatch_get_main_queue(), ^{
                    self.imgView.image = image;
                });
}

-(UIImageView *)imgView{
    
    if (!_imgView) {
        _imgView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

@end
