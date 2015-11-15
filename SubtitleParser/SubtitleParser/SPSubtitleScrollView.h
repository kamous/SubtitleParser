//
//  SPSubtitleScrollView.h
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPSubtitles.h"

/**
 *  字幕显示文件
 */
@interface SPSubtitleScrollView : UIScrollView

@property (nonatomic, strong) SPSubtitles* subtitles;


/**
 *  根据时间滚动字幕
 *
 *  @param time 时间，单位秒
 */
- (void)updateWithTime:(NSTimeInterval)time;

@end
