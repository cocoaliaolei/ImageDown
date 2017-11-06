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
typedef NS_ENUM(NSInteger,ImageCacheOptions) {
    
    CacheNone = 0,//不缓存
    CacheOneDay,  //缓存一天
    CacheOneWeek, //缓存一周
    CacheOneMonth //缓存一月
    
};

@protocol LLImageLoadBitDelegate<NSObject>
@optional
-(void)LLImageLoadBitDiddidReceiveGetImages:(UIImage *)image;
@end

@interface LLImageLoadBit : NSObject
//@property (nonatomic,weak)id<LLImageLoadBitDelegate>delegate;
-(void)initWithUrl:(NSString *)imageUrl withType:(ImageTypeOptions)option withBlock:(void(^)(UIImage *image))imgBlock withCatheOptions:(ImageCacheOptions)cacheOption;

-(void)initWithUrl:(NSString *)imageUrl withDelegate:(id<LLImageLoadBitDelegate>)delegate withType:(ImageTypeOptions)option withCatheOptions:(ImageCacheOptions)cacheOption;

@end
