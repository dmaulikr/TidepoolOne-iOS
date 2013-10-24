//
//  TPEchoStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoStageViewController.h"
#import "TPEchoCircleView.h"

@interface TPEchoStageViewController () <TPEchoCircleViewDelegate>
{
    NSArray *_pattern;
    NSMutableArray *_circles;
    int _currentIndex;
    int _currentMaxIndex;
}
@end

@implementation TPEchoStageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _circles = [@[] mutableCopy];
    _currentIndex = 0;
    _currentMaxIndex = 0;
    float radius = 100;
    float viewDimensions = 100;
    int numCircles = 7;
    NSArray *colors = @[
                        [UIColor colorWithRed:64/255.0 green:191/255.0 blue:239/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:205/255.0 blue:2/255.0 alpha:1],
                        [UIColor colorWithRed:231/255.0 green:57/255.0 blue:36/255.0 alpha:1],
                        [UIColor colorWithRed:146/255.0 green:92/255.0 blue:147/255.0 alpha:1],
                        [UIColor colorWithRed:139/255.0 green:200/255.0 blue:103/255.0 alpha:1],
                        [UIColor colorWithRed:240/255.0 green:94/255.0 blue:116/255.0 alpha:1],
                        [UIColor colorWithRed:240/255.0 green:148/255.0 blue:32/255.0 alpha:1],
                        
    ];
    for (int i = 0; i< numCircles; i++) {
        TPEchoCircleView *circle = [[TPEchoCircleView alloc] initWithFrame:CGRectMake(0, 0, viewDimensions, viewDimensions)];
        circle.delegate = self;
        circle.backgroundColor = [UIColor clearColor];
        circle.color = colors[i];
        float theta = 2.0*M_PI * i / numCircles;
        CGPoint point = CGPointMake(self.view.center.x + radius*cosf(theta), self.view.center.y + radius*sinf(theta));
        circle.center = point;
        [self.view addSubview:circle];
        [_circles addObject:circle];
    }
    [self generatePattern];
    [self moveMaxIndex];
}

-(void)generatePattern
{
    int patternLength = 10;
    NSMutableArray *pattern = [@[] mutableCopy];
    for (int i=0; i<patternLength;i++) {
        [pattern addObject:[NSNumber numberWithInt:rand()%7]];
    }
    _pattern = pattern;
}

-(void)moveMaxIndex
{
    _currentMaxIndex++;
    _currentIndex = 0;
    NSLog(@"move index to : %i", _currentMaxIndex);
    [self playPattern:_pattern tillIndex:_currentMaxIndex];
}


-(void)playPattern:(NSArray *)pattern tillIndex:(int) index
{
    for (int i=0;i<index;i++) {
        [NSTimer scheduledTimerWithTimeInterval:0.75*i target:_circles[[pattern[i] intValue]] selector:@selector(play) userInfo:nil repeats:NO];
    }
}

-(void)tappedCircle:(TPEchoCircle *)circle
{
    int circleIndex = [_circles indexOfObject:circle];
    if (circleIndex == [_pattern[_currentIndex] intValue]) {
        _currentIndex++;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Wrong" message:@"You suck!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
    if (_currentIndex == _currentMaxIndex) {
        [self moveMaxIndex];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
