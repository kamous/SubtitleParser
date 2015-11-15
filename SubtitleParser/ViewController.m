//
//  ViewController.m
//  SubtitleParser
//
//  Created by kamous on 15/11/15.
//  Copyright © 2015年 wjw. All rights reserved.
//

#import "ViewController.h"
#import "SPSubtitleParser.h"
#import "SPSubtitleScrollView.h"
#import "Masonry.h"

@interface ViewController ()
@property (nonatomic, strong) SPSubtitleScrollView *subtitleView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubtitleView];
    [self testParser];
    [self startTimer];
}

- (void)testParser{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"srt"];
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    __weak ViewController *ws = self;
    [[SPSubtitleParser shareManager] parserText:content completion:^(SPSubtitles *subtitle) {
        NSLog(@"Result:%@",subtitle);
        [ws.subtitleView setSubtitles:subtitle];
    }];
}

- (void)initSubtitleView{
        if (self.subtitleView) {
            return;
        }
        SPSubtitleScrollView *subtitleView = [[SPSubtitleScrollView alloc] init];
        [self.view addSubview:subtitleView];
        [subtitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(60,20,120,20));
        }];
        self.subtitleView = subtitleView;
}


#define kSPTimeInterval 0.1
- (void)startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kSPTimeInterval target:self selector:@selector(onUpdateSubtitles) userInfo:nil repeats:YES];
}

- (void)onUpdateSubtitles{
    static float time = 0;
    time += kSPTimeInterval;
    [self.subtitleView updateWithTime:time];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
