//
//  LLimageCache.h
//  ImageDown
//
//  Created by 廖磊 on 2017/10/20.
//  Copyright © 2017年 东边的风. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLImageLoadBit.h"
@interface LLimageCache : NSObject


+(NSData *)getCacheImageData:(NSURL *)path withCacheOptions:(ImageCacheOptions)option;

+(BOOL)cacheImageData:(NSData *)imageData withPath:(NSURL *)imagePathUrl;


@end
