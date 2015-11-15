//
//  SPSubtitles.m
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import "SPSubtitles.h"
#import "SPSubtitleItem.h"

@implementation SPSubtitles

- (NSString*)description{
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"【Total Line:%ld】\n",[self.items count]];
    for (SPSubtitleItem *item in self.items) {
        [info appendFormat:@"%@\n",[item description]];
    }
    return info;
}

@end
