//
//  SPSubtitleScrollView.m
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import "SPSubtitleScrollView.h"
#import "SPSubtitleItem.h"
#import "Masonry.h"

@interface SPSubtitleScrollView()

@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highLightColor;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) int curLine;      //根据字幕文件，从1开始
@property (nonatomic, assign) int lastLineIndex;//带index的从0开始
@property (nonatomic, assign) CGFloat curY;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, assign) CGFloat labelHeight;

@end

@implementation SPSubtitleScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}


- (void)setSubtitles:(SPSubtitles *)subtitles{
    _subtitles = subtitles;
    
    if ([subtitles.items count] == 0) {
        return;
    }
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    long lineNum = [subtitles.items count];
    UIView *lastView = nil;
    
    for (int i = 0; i < lineNum; i++) {
        SPSubtitleItem *item = [subtitles.items objectAtIndex:i];
        
        UILabel *label = [UILabel new];
        [self.containerView addSubview:label];
        [label setNumberOfLines:0];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:item.text];
        [label setTextColor:self.textColor];
        [label setFont:[UIFont systemFontOfSize:17]];
        [label setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [label setShadowOffset:CGSizeMake(0, 1)];
        if (self.labelHeight < 0.1) {
            self.labelHeight = 21;
        }
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if (!lastView) {
                make.top.equalTo(self.containerView.mas_top);
            }else{
                make.top.equalTo(lastView.mas_bottom).offset(self.lineSpace);
            }
            make.left.and.right.equalTo(self.containerView).offset(0);
            make.centerX.equalTo(self.containerView.mas_centerX);
        }];
        [self.labels addObject:label];
        lastView = label;
        
    }
    
    [self updateHightListLine:0];
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.mas_bottom);
    }];
    
}

#pragma mark - 私有方法
- (void)commonInit
{
    self.containerView = [UIView new];
    self.labels = [NSMutableArray array];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self);
    }];
    
    //设置UI样式
    [self setTextColor:[UIColor whiteColor]];
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self setHighLightColor:[UIColor redColor]];
    [self setLineSpace:8];
    self.lastLineIndex = -1;
}

/*!
 设置当前播放到哪行，并滚动字幕和更新高亮。
 从1开始，如果还没播放到第一行，则设为0
 
 @param curLine 当前播放的行数
 */
- (void)setCurLine:(int)curLine{
    _curLine = curLine;
    long lineNum = [self.subtitles.items count];
    if (curLine <= lineNum) {
        int curIndex = curLine - 1;//curIndex为-1时，表示不高亮任何一行
        if (curIndex < 0) {
            self.curY =0;
        }else{
            self.curY = ((UILabel*)[self.labels objectAtIndex:curIndex]).frame.origin.y;
        }
        
        if (curIndex < 0 ||
            curIndex != self.lastLineIndex) {
            //滚动
            [self setContentOffset:CGPointMake(0, self.curY) animated:YES];
            
            //更新高亮
            //延后一点时间，否则高亮行会跳到第二行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateHightListLine:curLine];
            });
        }
        
        self.lastLineIndex = curIndex;
        
    }
}

/**
 *  高亮某一行，以及在录制模式下减少倒数两行透明度
 *
 *  @param curLineIndex 需要高亮的行
 */
- (void)updateHightListLine:(int)curLine{
    int curIndex = curLine - 1;
    
    for (int i = 0; i < [self.subtitles.items count]; i++) {
        UILabel *label = [self.labels objectAtIndex:i];
        [label setAlpha:1];
        if (curIndex == i) {
            [label setTextColor:self.highLightColor];
        }else{
            [label setTextColor:self.textColor];
        }
        
    }
}

#pragma mark - 接口
/*!
 根据当前播放到的时间来滚动字幕
 
 @param time 当前播放到得时间
 */
- (void)updateWithTime:(NSTimeInterval)time{
    
    if ([self.subtitles.items count] > 0) {
        if (time < ((SPSubtitleItem*)[self.subtitles.items firstObject]).startTime) {
            self.curLine = 0;
            return;
        }else if(time >= ((SPSubtitleItem*)[self.subtitles.items lastObject]).endTime){
            self.curLine = (int)[self.subtitles.items count];
            return;
        }
    }
    
    for (int i = 0 ; i < [self.subtitles.items count]; i++){
        SPSubtitleItem *item = [self.subtitles.items objectAtIndex:i];
        if (time >= item.startTime && time < item.endTime) {
            self.curLine = item.lineNo;
            break;
        }
    }
}
@end
