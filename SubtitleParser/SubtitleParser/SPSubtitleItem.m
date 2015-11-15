//
//  SPSubtitleItem.m
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import "SPSubtitleItem.h"

@implementation SPSubtitleItem

- (NSString*)description{
    NSString *info = [[NSString alloc] initWithFormat:@"%d: %f-->%f %@",self.lineNo, self.startTime, self.endTime, self.text];
    return info;
}

@end
