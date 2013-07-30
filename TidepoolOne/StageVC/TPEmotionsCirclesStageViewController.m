//
//  TPEmotionsCirclesStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEmotionsCirclesStageViewController.h"
#import "TPCustomScrollView.h"

@interface TPEmotionsCirclesStageViewController ()
{
    TPCustomScrollView *_scrollView;
    UIView *_mainView;
    NSMutableArray *_mainCircles;
    NSMutableArray *_scrollCircles;
    float _scrollViewY;
}
@end

@implementation TPEmotionsCirclesStageViewController

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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _circles = [NSMutableArray array];
    _mainCircles = [NSMutableArray array];
    [self createMainView];
    [self logTestStarted];
}


-(void)createMainView
{
    _mainView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mainView.clipsToBounds = YES;
    _mainView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_mainView];
    NSArray *circles = self.data[@"circles"];
    for (int i=0; i < circles.count; i++ ) {
        NSMutableDictionary *circle = [NSMutableDictionary dictionary];
        [circle setValue:circles[i][@"trait1"] forKey:@"trait1"];
        [_circles addObject:circle];
        UIImage *img = [UIImage imageNamed:@"reaction_time_disc_a.jpg"];
        UIImage *imgB = [UIImage imageNamed:@"reaction_time_disc_b.jpg"];
        float theta = 2 * M_PI / circles.count * i;
        float r = 50;
        float x = _mainView.center.x + r * cosf(theta);
        float y = _mainView.center.y + r * sinf(theta);
        TPCirclesDistanceView *circlesViewMain = [[TPCirclesDistanceView alloc] initWithFrame:CGRectMake(x, y, 50, 50)];
        circlesViewMain.image = img;
        circlesViewMain.delegate = self;
        
        [_mainCircles addObject:circlesViewMain];
        [_mainView addSubview:circlesViewMain];
        
        UIImageView *centerCircle = [[UIImageView alloc] initWithFrame:CGRectMake(_mainView.center.x, _mainView.center.x, 50, 50)];
        centerCircle.image = imgB;
        [_mainView addSubview:centerCircle];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        doneButton.frame = CGRectMake(10, 10, 50, 30);
        [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:doneButton];
    }
}




-(void)createScrollViewMainViewSplit
{
    _scrollCircles = [NSMutableArray array];
    float scrollViewHeight = 80;
    _scrollViewY = self.view.bounds.size.height - scrollViewHeight - 80;
    _scrollView = [[TPCustomScrollView alloc] initWithFrame:CGRectMake(0, _scrollViewY, self.view.bounds.size.width, scrollViewHeight)];
    _scrollView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_scrollView];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, _scrollViewY)];
    _mainView.clipsToBounds = YES;
    _mainView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_mainView];
    NSArray *circles = self.data[@"circles"];
    for (int i=0; i < circles.count; i++ ) {
        NSMutableDictionary *circle = [NSMutableDictionary dictionary];
        [circle setValue:circles[i][@"trait"] forKey:@"trait1"];
        [_circles addObject:circle];
        UIImage *img = [UIImage imageNamed:@"reaction_time_disc_a.jpg"];
        UIImage *imgB = [UIImage imageNamed:@"reaction_time_disc_b.jpg"];
        TPCirclesDistanceView *circlesViewMain = [[TPCirclesDistanceView alloc] initWithFrame:CGRectMake(55*i, _scrollViewY, 50, 50)];
        circlesViewMain.image = img;
        circlesViewMain.delegate = self;
        
        TPCirclesDistanceView *circlesViewScroll = [[TPCirclesDistanceView alloc] initWithFrame:CGRectMake(75*i, 0, 50, 50)];
        circlesViewScroll.image = imgB;
        circlesViewScroll.delegate = self;
        
        [_scrollCircles addObject:circlesViewScroll];
        [_mainCircles addObject:circlesViewMain];
        [_mainView addSubview:circlesViewMain];
        [_scrollView addSubview:circlesViewScroll];
        _scrollView.canCancelContentTouches = YES;
        CGSize oldScrollSize = _scrollView.contentSize;
        oldScrollSize.width += 155;
        _scrollView.contentSize = oldScrollSize;
        
        
        UIImageView *centerCircle = [[UIImageView alloc] initWithFrame:CGRectMake(_mainView.center.x, _mainView.center.x, 50, 50)];
        centerCircle.image = imgB;
        [_mainView addSubview:centerCircle];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doneButtonPressed:(id)sender {
    [self logTestCompleted];
    [self.gameVC currentStageDone];
}

-(bool)shouldAllowMoveCircle
{
    return YES;
}
-(void)moveCircle:(TPCirclesDistanceView *)circle toPoint:(CGPoint)point;
{
    circle.center = point;
    if (_scrollView) {
        int index;
        CGPoint pointOffset = point;
        CGPoint scrollViewOffset = _scrollView.contentOffset;
        TPCirclesDistanceView *otherCircle;
        if ([_mainCircles containsObject:circle]) {
            index = [_mainCircles indexOfObject:circle];
            pointOffset.x += scrollViewOffset.x;
            pointOffset.y -= _scrollViewY;
            otherCircle = _scrollCircles[index];
            otherCircle.center = pointOffset;
        } else if ([_scrollCircles containsObject:circle]) {
            pointOffset.x -= scrollViewOffset.x;
            index = [_scrollCircles indexOfObject:circle];
            pointOffset.y += _scrollViewY;
            otherCircle = _mainCircles[index];
            otherCircle.center = pointOffset;
        }
    }
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *completeEvents = [event mutableCopy];
    [completeEvents setValue:@"emotions_circles" forKey:@"module"];
    [self.gameVC logEvent:completeEvents];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_started" forKey:@"event_desc"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    NSMutableDictionary *selfCoord = [NSMutableDictionary dictionary];
    [selfCoord setValue:@4 forKey:@"size"];
    [selfCoord setValue:@140 forKey:@"top"];
    [selfCoord setValue:@699 forKey:@"left"];
    
    
    for (NSMutableDictionary *circle in _circles) {
        [circle setValue:@4 forKey:@"size"];
        [circle setValue:@140 forKey:@"top"];
        [circle setValue:@699 forKey:@"left"];
        [circle setValue:@198 forKey:@"width"];
    }
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_completed" forKey:@"event_desc"];
    [event setValue:_circles forKey:@"circles"];
    [event setValue:selfCoord forKey:@"self_coord"];
    [self logEventToServer:event];
}


@end
