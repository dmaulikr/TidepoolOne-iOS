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
    NSDictionary *_buttonImages;
    NSMutableArray *_timers;
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
    _timers = [NSMutableArray array];
    // Do any additional setup after loading the view from its nib.
    
    _buttonImages = @{
                     @"normal":[UIImage imageNamed:@"btn-faceoff-white-big.png"],
                     @"correct":[UIImage imageNamed:@"btn-faceoff-correct-big.png"],
                     @"incorrect":[UIImage imageNamed:@"btn-faceoff-wrong-big.png"],
                     };

    [self.imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.imageView.layer setBorderWidth: 5.0];
    
    [self logLevelStartedWithAdditionalData:@{
                                              @"primary_multiplier":@2.0,
                                              @"secondary_multiplier":@1.0,
                                              @"time_to_show":@999,
                                              }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instantReplay)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tap];
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
                        self.imageIsHidden = !self.imageIsHidden;
                        if (self.imageIsHidden) {
                            self.imageView.image = [UIImage imageNamed:@"faceoff-photo-replay.png"];;
                        } else {
                            self.imageView.image = [UIImage imageNamed:self.imagesData[_imageIndex][@"path"]];
                        }
                    } completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)emotionChosen:(id)sender
{
    UIButton *button = (UIButton *)sender;
    BOOL correct;
    correct = [self logCurrentResponse:button.titleLabel.text];
    [self updateButonLooks:button forCorrect:correct];
    [self showAnimationFromButton:button forCorrect:correct];
    [_timers addObject:[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(moveToNextPart) userInfo:nil repeats:NO]];
}

-(void)updateButonLooks:(UIButton *)button forCorrect:(BOOL)correct
{
    if (correct) {
        self.imageView.image = [UIImage imageNamed:@"faceoff-photo-correct.png"];
        [button setBackgroundImage:_buttonImages[@"correct"] forState:UIControlStateNormal];
    } else {
        self.imageView.image = [UIImage imageNamed:@"faceoff-photo-wrong.png"];
        [button setBackgroundImage:_buttonImages[@"incorrect"] forState:UIControlStateNormal];
    }
}

-(void)showAnimationFromButton:(UIButton *)button forCorrect:(BOOL)correct
{
    NSArray *images = @[@"points-wrong.png", @"points-correct.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[correct]]];
    imageView.center = [self.view convertPoint:button.center fromView:self.drawerView];
        self.view.userInteractionEnabled = NO;
    [self.view addSubview:imageView];
    [UIView animateWithDuration:1.0 animations:^{
        imageView.center = self.scoreLabel.center;
        imageView.alpha = 0.3;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        self.view.userInteractionEnabled = YES;        
    }];
}


-(void)moveToNextPart
{
    // not asking twice for same pic
//    if (self.secondary) {
//        if (self.isSecondary) {
//            [self showNextEmotion];
//        } else {
//            [self showSecondaryEmotion];
//        }
//    } else {
        [self showNextEmotion];
//    }
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
        for (NSTimer *timer in _timers) {
            [timer invalidate];
        }
        [self logLevelCompleted];
        [self stageOver];
        return;
    }
    self.imageIsHidden = NO;
    self.imageView.image = [UIImage imageNamed:self.imagesData[_imageIndex][@"path"]];
    [_timers addObject:[NSTimer scheduledTimerWithTimeInterval:self.timeToShow/1000 target:self selector:@selector(flipImage) userInfo:nil repeats:NO]];
    NSArray *emotionOptions = self.imagesData[_imageIndex][@"emotions"];
    if (emotionOptions.count == 3) {
        [self.emo_3_0 setTitle:emotionOptions[0] forState:UIControlStateNormal];
        [self.emo_3_1 setTitle:emotionOptions[1] forState:UIControlStateNormal];
        [self.emo_3_2 setTitle:emotionOptions[2] forState:UIControlStateNormal];
        
        [self.emo_3_0 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];
        [self.emo_3_1 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];
        [self.emo_3_2 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];
        self.emo_4_0.hidden = self.emo_4_1.hidden = self.emo_4_2.hidden = self.emo_4_3.hidden = YES;

        self.emo_3_0.hidden = self.emo_3_1.hidden = self.emo_3_2.hidden = NO;
        
    } else if (emotionOptions.count == 4) {
        [self.emo_4_0 setTitle:emotionOptions[0] forState:UIControlStateNormal];
        [self.emo_4_1 setTitle:emotionOptions[1] forState:UIControlStateNormal];
        [self.emo_4_2 setTitle:emotionOptions[2] forState:UIControlStateNormal];
        [self.emo_4_3 setTitle:emotionOptions[3] forState:UIControlStateNormal];
        
        [self.emo_4_0 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];
        [self.emo_4_1 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];
        [self.emo_4_2 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];
        [self.emo_4_3 setBackgroundImage:_buttonImages[@"normal"] forState:UIControlStateNormal];

        self.emo_4_0.hidden = self.emo_4_1.hidden = self.emo_4_2.hidden = self.emo_4_3.hidden = NO;

        self.emo_3_0.hidden = self.emo_3_1.hidden = self.emo_3_2.hidden = YES;
    }
    
    self.primary = self.imagesData[_imageIndex][@"primary"];
    if (self.imagesData[_imageIndex][@"secondary"] != [NSNull null]) {
        self.secondary = self.imagesData[_imageIndex][@"secondary"];
    } else {
        self.secondary = nil;
    }
    self.isSecondary = NO;
}

-(BOOL)logCurrentResponse:(NSString *)choice
{
    BOOL correct;
    NSArray *correctString = @[@"incorrect", @"correct"];
//    if (self.isSecondary) {
//        correct = [choice isEqualToString:self.secondary];
//    } else {
//        correct = [choice isEqualToString:self.primary];
//    }
    correct = ([choice isEqualToString:self.secondary] || [choice isEqualToString:self.primary]);
    NSArray *modes = @[@"primary",@"secondary"];
    NSDictionary *event = @{
                            @"event":correctString[correct],
                            @"value":choice,
                            @"type":modes[_isSecondary],
                            @"instant_replay":[NSNumber numberWithInt:_instantReplayCount],
                            };
    [self logEventToServer:event];
    return correct;
}

-(void)setIsSecondary:(BOOL)isSecondary
{
    _isSecondary = isSecondary;
    if (_isSecondary) {
        // TODO: SETUP THE RIGHT THINGS
    }
}

-(void)instantReplay
{
    if (self.imageIsHidden) {
        [self flipImage];
        _instantReplayCount++;
        [_timers addObject:[NSTimer scheduledTimerWithTimeInterval:self.timeToShow/1000 target:self selector:@selector(flipImage) userInfo:nil repeats:NO]];
    }
}

@end
