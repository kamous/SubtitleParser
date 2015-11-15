//
//  SPSubtitleItem.h
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  一行字幕
 */
@interface SPSubtitleItem : NSObject

@property (nonatomic, assign) int lineNo;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, strong) NSString *text;

@end
