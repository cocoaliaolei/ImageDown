//
//  LLImageLoadBit.m
//  Category
//
//  Created by 廖磊 on 2017/10/11.
//  Copyright © 2017年 廖磊. All rights reserved.
//

#import "LLImageLoadBit.h"
#import <ImageIO/ImageIO.h>
#import "LLimageCache.h"

@interface LLImageLoadBit ()<NSURLSessionDataDelegate>

@property (nonatomic,copy) void(^block)(UIImage *image);
@property (nonatomic,assign)CGImageSourceRef incrementallyImgSource;
@property (nonatomic,strong)NSMutableData *imgData;
@property (nonatomic,strong)NSMutableData *TempImgData;//临时存放数据，到一定量才转换成image
@property (nonatomic,assign)BOOL isDownloadFinished;//是否下载完成
@property (nonatomic,assign)BOOL isNeedCache;//是否需要缓存
@property (nonatomic,assign)long long expectedLeght;//数据总长度
@property (nonatomic,assign)ImageCacheOptions caCheTypeOption;//缓存类型
@property (nonatomic,weak)id<LLImageLoadBitDelegate>delegate;

@end

@implementation LLImageLoadBit

-(void)dealloc{
    
    NSLog(@"%s",__FUNCTION__);
    
    CFRelease(self.incrementallyImgSource);
    _incrementallyImgSource = NULL;
    
}

-(CGImageSourceRef)incrementallyImgSource{
    
    if (!_incrementallyImgSource) {
        _incrementallyImgSource = CGImageSourceCreateIncremental(NULL);
    }
    return _incrementallyImgSource;
}

-(NSMutableData *)imgData{
    if (!_imgData) {
        _imgData = [[NSMutableData alloc]init];
    }
    return _imgData;
}

-(NSMutableData *)TempImgData{
    if (!_TempImgData) {
        _TempImgData = [[NSMutableData alloc]init];
    }
    return _TempImgData;
}

/**
 * block模式方法
 */
-(void)initWithUrl:(NSString *)imageUrl withType:(ImageTypeOptions)option withBlock:(void (^)(UIImage *))imgBlock withCatheOptions:(ImageCacheOptions)cacheOption {
    
    self.isNeedCache = YES;
    if (cacheOption == CacheNone) self.isNeedCache = NO;
    self.caCheTypeOption = cacheOption;
    self.block = imgBlock;
    [self imageReqest:imageUrl withType:option];
    
}

-(void)imageReqest:(NSString *)imageUrl withType:(ImageTypeOptions)option{
    switch (option) {
        case signalImage:
            [self signalRequestSet:imageUrl];
            break;
        case gifImages:
            [self gifRequestSet:imageUrl];
            break;
        default:
            break;
    }
}

-(void)gifRequestSet:(NSString *)url{
    
    if (self.isNeedCache) {
        NSData *imgData = [LLimageCache getCacheImageData:[NSURL URLWithString:url] withCacheOptions:self.caCheTypeOption];
        if (imgData) {
            [self gifImageHandle:imgData withUrl:url];
        }
        else [self gifRequestWith:url];
    }
    else [self gifRequestWith:url];
    
}

-(void)gifRequestWith:(NSString *)url{
    /**
     *NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
     *CGImageSourceRef myImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imgData,NULL);
     */

    /**
     *放到线程里去下载
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        /**
         *第一种
         */
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        /**
         *缓存
         */
        if (self.isNeedCache) {
            [LLimageCache cacheImageData:imgData withPath:[NSURL URLWithString:url]];
        }
        [self gifImageHandle:imgData withUrl:url];
    });
    
}
-(void)gifImageHandle:(NSData *)imgData withUrl:(NSString *)url{
    
    
    /**
     *第一种
     */
//    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    
    CGImageSourceRef myImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imgData,NULL);
    
    if (myImageSource == NULL){
        imgData = [NSData dataWithContentsOfFile:url];
        myImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imgData,NULL);
    }
    
    
    /**
     *第二种
     */
    
    /**
     *加载网络图片
     */
    //        CGImageSourceRef myImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL URLWithString:url], NULL);
    /**
     *加载本地图片
     */
    
    //        if (myImageSource == NULL) myImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:url], NULL);
    
    
    
    
    if (myImageSource == NULL) return;
    
    size_t count = CGImageSourceGetCount(myImageSource);
    
    UIImage *img = nil;
    if (count <= 1) {//一张图片
        CGImageRef imgRef = CGImageSourceCreateImageAtIndex(myImageSource, 0, NULL);
        img = [UIImage imageWithCGImage:imgRef];
    }
    else if(count > 1){//多张动图
        img = [self getCombineImages:myImageSource index:count];
    }
    /**
     * 数据处理完成后回调
     */
    [self returnImageWith:img];
    
    CFRelease(myImageSource);
}

/**
 * 将图片集成gif图片
 *
 */
-(UIImage *)getCombineImages:(CGImageSourceRef)myImageSource index:(size_t)count{
    
    NSMutableArray *aray = [[NSMutableArray alloc]init];
    
    CGFloat Durations = 0.0f;
    
    for (size_t i = 0; i < count; i ++) {
        
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(myImageSource, i, NULL);
        
        [aray addObject:[UIImage imageWithCGImage:imageRef]];
        
        Durations += [self getIndexImageDuration:myImageSource index:i];
        
        /**
         * 创建了CGImageRef实例就要release，不然内存爆炸💥
         */
        CGImageRelease(imageRef);
    }
    
    if (Durations == 0.0f) Durations = 0.1f * count;
    
    UIImage *img = [UIImage animatedImageWithImages:aray duration:Durations];
    
    return img;
}
/**
 * 获取每一张图片的时间
 */
-(CGFloat)getIndexImageDuration:(CGImageSourceRef)myImageSource index:(size_t)i{
    
    CGFloat indexDuration = 0.1f;
    CFDictionaryRef cfProperties =  CGImageSourceCopyPropertiesAtIndex(myImageSource, i, NULL);
    NSDictionary *timesDic = (__bridge NSDictionary *)cfProperties;
    NSDictionary *gifProperties = timesDic[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *UnclampedDelayTime = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (UnclampedDelayTime) {
        indexDuration = UnclampedDelayTime.floatValue;
    }
    else{
        NSNumber *DelayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (DelayTime) {
            indexDuration = DelayTime.floatValue;
        }
    }
    if (indexDuration < 0.01f) indexDuration = 0.1f;
    CFRelease(cfProperties);
    return indexDuration;
}
#pragma mark - signalRequestSet
/**
 * 下载单张图片，缓慢加载并显示
 * 不用connection了，Apple现在推荐使用NSURLSession。
 */
-(void)signalRequestSet:(NSString *)url{
    
    if (self.isNeedCache) {
        NSData *imgData = [LLimageCache getCacheImageData:[NSURL URLWithString:url] withCacheOptions:self.caCheTypeOption];
        if (imgData) [self returnImageWith:[UIImage imageWithData:imgData]];
        else [self signalRequestWith:url];
    }
    else [self signalRequestWith:url];
    
}

-(void)signalRequestWith:(NSString *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sesson = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [sesson dataTaskWithRequest:request];
    [task resume];
}
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.expectedLeght = response.expectedContentLength;
    NSLog(@"---expectedLeght:%lld",self.expectedLeght);
    completionHandler(NSURLSessionResponseAllow);
}



-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    [self.imgData appendData:data];
//    NSLog(@"%ld",data.length);
    [self.TempImgData appendData:data];
    
    if (self.imgData.length == self.expectedLeght) self.isDownloadFinished = YES;
    /**
     * 40这个值的设置是根据每次didReceiveData的数据长度估算的一个值
     * 这里不能每次接收到数据就将其转换为图片，这样对cpu消耗太大，容易引起崩溃
     */
    
    if (self.TempImgData.length > self.expectedLeght/40 || self.expectedLeght == self.imgData.length) {
        self.TempImgData = nil;
        UIImage *img = [self creatImageWithData];
        if (self.isNeedCache && self.expectedLeght == self.imgData.length) {
            [LLimageCache cacheImageData:self.imgData withPath:dataTask.response.URL];
        }
        [self returnImageWith:img];
    }
}
-(void)returnImageWith:(UIImage *)img{
    if (self.block) self.block(img);
    else if (self.delegate){
        if ([_delegate respondsToSelector:@selector(LLImageLoadBitDiddidReceiveGetImages:)]) {
            [_delegate LLImageLoadBitDiddidReceiveGetImages:img];
        }
    }
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (error) NSLog(@"下载出错!!!---%@",error);
    /**
     * 释放session，防止内存泄漏
     */
    [session finishTasksAndInvalidate];
}


/**
 * 将接收到的数据转换为图片
 */
-(UIImage *)creatImageWithData{
    
    CGImageSourceUpdateData(self.incrementallyImgSource, (__bridge CFDataRef)self.imgData, false);
    CGImageRef imgRef =   CGImageSourceCreateImageAtIndex(self.incrementallyImgSource, 0, NULL);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return img;
    
}

/**
 * 代理模式方法
 */
#pragma mark - LLImageLoadBitDelegate
-(void)initWithUrl:(NSString *)imageUrl withDelegate:(id<LLImageLoadBitDelegate>)delegate withType:(ImageTypeOptions)option withCatheOptions:(ImageCacheOptions)cacheOption{
        self.delegate = delegate;
        [self imageReqest:imageUrl withType:option];
}

@end
