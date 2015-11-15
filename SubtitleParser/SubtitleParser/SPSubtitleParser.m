//
//  SPSubtitleParser.m
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import "SPSubtitleParser.h"
#import "SPSubtitleItem.h"


@interface SPSubtitleParser()

@property (nonatomic, strong) NSString* content;

@end

@implementation SPSubtitleParser

+ (SPSubtitleParser*)shareManager{
    static SPSubtitleParser *_shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[SPSubtitleParser alloc]init];
    });
    return _shareManager;
}

/**
 *  解析字幕文件内容
 *
 *  @param content    字幕文件内容
 *  @param completion 解析完成后的回调，返回解析得到的SPSubtitles对象
 */
- (void)parserText:(NSString*)content completion:(void(^)(SPSubtitles *subtitle))completion{
    self.content = content;
    if (!content || [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return;
    }
    dispatch_async(dispatch_queue_create("Subtitle Parser",0),^{
        SPSubtitles *subtitles = [[SPSubtitles alloc] init];
        
        NSMutableArray *items = [NSMutableArray array];
        
        //按空行分割成多个item
        self.content = [self.content stringByReplacingOccurrencesOfString:@"\n\r\n" withString:@"\n\n"];
        NSArray *subStrings = [self.content componentsSeparatedByString:@"\n\n"];
        
        for (int i = 0 ; i < [subStrings count]; i++) {
            NSString *str = [subStrings objectAtIndex:i];
            SPSubtitleItem *item = [self parserToSubtitleItem:str];
            if (item) {
                [items addObject:item];
            }
        }
        subtitles.items = items;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(subtitles);
            }
        });
    });
}


/**
 *  解析单个字幕item
 *
 *  @param content item的内容，通常为三行文本
 *
 *  @return 解析得到的SPSubtitleItem对象
 */
- (SPSubtitleItem*)parserToSubtitleItem:(NSString*)content{
    if ([content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return nil;
    }
    
    //两段字幕都只有行号和时间，没有文本内容时，解析后第二段字幕会以\r\n开头
	if ([content hasPrefix:@"\r\n"] && content.length > 2) {
        content = [content substringFromIndex:2];
    }
    
    //以换行符分割单个item的字幕内容
    NSArray *lines = [content componentsSeparatedByString:@"\r\n"];
    if ([lines count] >= 2) {
        SPSubtitleItem *item = [[SPSubtitleItem alloc]init];
        item.lineNo = [[lines objectAtIndex:0] intValue];
        
        NSArray *times = [[lines objectAtIndex:1] componentsSeparatedByString:@"-->"];
        if ([times count] == 2) {
            NSString *startTimeStr = [[times objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *endTimeStr = [[times objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            item.startTime = [self timeIntervalFromSubtitleTimeString:startTimeStr];
            item.endTime = [self timeIntervalFromSubtitleTimeString:endTimeStr];
        }else{
            return nil;
        }
        
        //字幕显示的内容
        NSMutableString *text = [NSMutableString string];
        for (int i = 2; i < [lines count]; i++) {
            [text appendFormat:@"%@\n",[lines objectAtIndex:i]];
        }
        if ([text hasSuffix:@"\r\n"]) {
            text = [[text substringToIndex:(text.length -2)] mutableCopy];
        }
        if ([lines count] == 2 && text.length == 0) {//处理空行的特殊情况
            [text appendString:@"\r"];
        }
        item.text = text;
        
        return item;
    }else{
        return nil;
    }
    
    
}

/**
 *  字幕中的时间格式字符串转为NSTimeInterval
 *
 *  @param str 00:00:04,120样式字符串
 *
 *  @return NSTimeInterval
 */
- (NSTimeInterval)timeIntervalFromSubtitleTimeString:(NSString*)str{
    
    NSArray *miliArray = [str componentsSeparatedByString:@","];
    int miliseconds = 0;
    if ([miliArray count] >= 2) {
        miliseconds = [[miliArray objectAtIndex:1] intValue];
    }
    int second = 0;
    int hour = 0;
    int minute = 0;
    if ([miliArray count] > 1) {
        NSArray *timeArray = [[miliArray objectAtIndex:0] componentsSeparatedByString:@":"];
        if ([timeArray count] >= 3) {
            hour = [[timeArray objectAtIndex:0] intValue];
            minute = [[timeArray objectAtIndex:1] intValue];
            second = [[timeArray objectAtIndex:2] intValue];
        }
    }
    return hour * 60 * 60 + minute * 60 + second + miliseconds/1000.0;
}


@end
