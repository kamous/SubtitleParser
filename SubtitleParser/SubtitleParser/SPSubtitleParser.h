//
//  SPSubtitleParser.h
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSubtitles.h"

/**
 *  字幕解析器
 */
@interface SPSubtitleParser : NSObject


+ (SPSubtitleParser*)shareManager;

/**
 *  解析字幕文件内容
 *
 *  @param content    字幕文件内容
 *  @param completion 解析完成后的回调，返回解析得到的SPSubtitles对象
 */
- (void)parserText:(NSString*)content completion:(void(^)(SPSubtitles *subtitle))completion;

@end
