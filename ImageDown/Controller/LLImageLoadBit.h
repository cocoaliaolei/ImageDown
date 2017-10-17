//
//  LLImageLoadBit.h
//  Category
//
//  Created by 廖磊 on 2017/10/11.
//  Copyright © 2017年 廖磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class LLImageLoadBit;



typedef NS_ENUM(NSInteger,ImageTypeOptions){
    signalImage = 0,//一张大图片缓慢加载，一点一点地显示图片
    gifImages//一张或gif图片加载
};

@protocol LLImageLoadBitDelegate<NSObject>
@optional
-(void)LLImageLoadBitDiddidReceiveGetImages:(UIImage *)image;
@end

@interface LLImageLoadBit : NSObject
//@property (nonatomic,weak)id<LLImageLoadBitDelegate>delegate;
-(void)initWithUrl:(NSString *)imageUrl withType:(ImageTypeOptions)option withBlock:(void(^)(UIImage *image))imgBlock;

-(void)initWithUrl:(NSString *)imageUrl withDelegate:(id<LLImageLoadBitDelegate>)delegate withType:(ImageTypeOptions)option;


@end
