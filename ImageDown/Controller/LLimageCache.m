//
//  LLimageCache.m
//  ImageDown
//
//  Created by 廖磊 on 2017/10/20.
//  Copyright © 2017年 东边的风. All rights reserved.
//

#import "LLimageCache.h"

@implementation LLimageCache

-(void)dealloc{
    
    NSLog(@"%s",__FUNCTION__);
    
}

+(NSData *)getCacheImageData:(NSURL *)path withCacheOptions:(ImageCacheOptions)option{
    BOOL flag = [self isHaveBeenCached:path.lastPathComponent withOptions:option];
    if (!flag) return nil;
    NSData *imgData = [self getCacheImageData:path.lastPathComponent];
    return imgData;
}

/**
 *读取缓存中img数据
 */
+(NSData *)getCacheImageData:(NSString *)path{
    
    NSString *filePath = [self getFilePath];
    
    if (!filePath) return nil;
    
    NSString *imagePath = [filePath stringByAppendingPathComponent:path];
    
//    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
//    NSLog(@"%@",filePath);
    
    return imgData;
}
/**
 *缓存-img
 */
+(BOOL)cacheImageData:(NSData *)imageData withPath:(NSURL *)imagePathUrl{
    
    NSString *filePath = [self getFilePath];
    NSLog(@"%@",filePath);
    if (!filePath) return NO;
    NSString *path = [filePath stringByAppendingPathComponent:imagePathUrl.lastPathComponent];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL success = [manager createFileAtPath:path contents:imageData attributes:nil];
    
    if (success) {
        NSLog(@"缓存成功！！！");
        [self saveDateWith:imagePathUrl.lastPathComponent];
    }else NSLog(@"缓存失败！！！");
    
    return success;
}

+(void)saveDateWith:(NSString *)keyPath{
    
    NSDate *date = [NSDate date];
    
//    NSDateFormatter *formatter = [self getTimeDateFormatter];
    
//    NSString *dateStr = [formatter stringFromDate:date];
    
    [[NSUserDefaults standardUserDefaults]setObject:date forKey:keyPath];
    
}

+(BOOL)isHaveBeenCached:(NSString *)imagePath withOptions:(ImageCacheOptions)option{
    long indexs = [self getTime:imagePath];
    switch (option) {
        case CacheNone:return NO;
            break;
        case CacheOneDay:if (indexs > 1) return NO;
            break;
        case CacheOneWeek:
            if (indexs > 7) return NO;
            break;
        case CacheOneMonth:
            if (indexs > 30) return NO;
            break;
        default:
            break;
    }
    return YES;
}

+(long)getTime:(NSString *)imagePath{
    
//    NSDateFormatter *formatter = [self getTimeDateFormatter];
    
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults]objectForKey:imagePath];
    
    if (!lastDate) return 0;
    
    NSTimeInterval index = [[NSDate date] timeIntervalSinceDate:lastDate];
    
    
    return index/(3600 * 24);
    
}
+(NSDateFormatter *)getTimeDateFormatter{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    return formatter;
}


+(NSString*)getFilePath{
    NSString *ph = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [ph stringByAppendingPathComponent:@"ImageDown"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) {
        if (![manager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil]) {
            NSLog(@"创建文件夹失败");
            return nil;
        }
        else NSLog(@"创建文件夹成功");
    }
    else NSLog(@"文件夹已经存在");
    return filePath;
}

@end

