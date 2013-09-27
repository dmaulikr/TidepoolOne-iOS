//
//  TPEIStagePickEmotionViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIStagePickEmotionViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TPEIStagePickEmotionViewController ()
{

}
@end

@implementation TPEIStagePickEmotionViewController

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
    self.type = @"faceoff";
    // Do any additional setup after loading the view from its nib.
    [self.emo_1 addTarget:self action:@selector(emotionChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.emo_2 addTarget:self action:@selector(emotionChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.emo_3 addTarget:self action:@selector(emotionChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.imageView.layer setBorderWidth: 5.0];
    
    [self logLevelStartedWithAdditionalData:@{
                                              @"primary_multiplier":@2.0,
                                              @"secondary_multiplier":@1.0,
                                              @"time_to_show":@999,
                                              }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"EI Stage Screen, %i",self.gameVC.stage]];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
    self.imageIndex = 0;
}

-(void)flipImage
{
    [UIView transitionWithView:self.imageView
                      duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.imageView.image = [UIImage imageNamed:@"faceoff-photo-replay.png"];;
                    } completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)emotionChosen:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self logCurrentResponse:button.titleLabel.text];
////    [super stageOver];
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        if (self.drawerView.transform.ty == 0) {
////            [self.drawerView setTransform:CGAffineTransformMakeTranslation(0, 400)];
//        } else {
////            [self.drawerView setTransform:CGAffineTransformMakeTranslation(0, 0)];
//        }
//    }completion:^(BOOL done){
//        //some completion handler
//        [sender setEnabled:YES];
//    }];
    
    //move to next part
    if (self.secondary) {
        if (self.isSecondary) {
            [self showNextEmotion];
        } else {
            [self showSecondaryEmotion];
        }
    } else {
        [self showNextEmotion];
    }
}

-(void)showSecondaryEmotion
{
    self.isSecondary = YES;
}

-(void)showNextEmotion
{
    self.imageIndex = self.imageIndex + 1;
}

-(void)setData:(NSDictionary *)data
{
    [super setData:data];
    if (data) {
        self.imagesData = data[@"images"];
        self.timeToShow = [data[@"time_to_show"] floatValue];
    }
}

-(void)setImageIndex:(int)imageIndex
{
    _imageIndex = imageIndex;
    if (_imageIndex == self.imagesData.count) {
        [self logLevelCompleted];
        [self stageOver];
        return;
    }
    self.imageView.image = [UIImage imageNamed:self.imagesData[_imageIndex][@"path"]];
    [NSTimer scheduledTimerWithTimeInterval:self.timeToShow/1000 target:self selector:@selector(flipImage) userInfo:nil repeats:NO];
    self.emo_1.titleLabel.text = self.imagesData[_imageIndex][@"emotions"][0];
    self.emo_2.titleLabel.text = self.imagesData[_imageIndex][@"emotions"][1];
    self.emo_3.titleLabel.text = self.imagesData[_imageIndex][@"emotions"][2];
    self.primary = self.imagesData[_imageIndex][@"primary"];
    if (self.imagesData[_imageIndex][@"secondary"] != [NSNull null]) {
        self.secondary = self.imagesData[_imageIndex][@"secondary"];
    } else {
        self.secondary = nil;
    }
    self.isSecondary = NO;
}

-(void)logCurrentResponse:(NSString *)choice
{
    BOOL correct;
    if (self.isSecondary) {
        correct = [choice isEqualToString:self.secondary];
    } else {
        correct = [choice isEqualToString:self.primary];
    }
    NSArray *modes = @[@"primary",@"secondary"];
    NSDictionary *event = @{
                            @"event":[NSNumber numberWithBool:correct],
                            @"value":choice,
                            @"type":modes[_isSecondary],
                            @"instant_replay":[NSNumber numberWithInt:_instantReplayCount],
                            };
    NSLog([event description]);
    [self logEventToServer:event];
}

-(void)setIsSecondary:(BOOL)isSecondary
{
    _isSecondary = isSecondary;
    if (_isSecondary) {
        // TODO: SETUP THE RIGHT THINGS
    }
}

@end
