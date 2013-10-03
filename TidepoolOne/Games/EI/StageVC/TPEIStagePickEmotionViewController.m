//
//  TPEIStagePickEmotionViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIStagePickEmotionViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum ChoiceCorrect {ChoiceCorrectNo, ChoiceCorrectPrimary, ChoiceCorrectSecondary} ChoiceCorrect;

@interface TPEIStagePickEmotionViewController ()
{
    NSDictionary *_buttonImages;
    NSMutableArray *_timers;
    int _score;
}
@end

@implementation TPEIStagePickEmotionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Identify the emotion";
        
        _incorrectBaseScore = -20;
        _correctBaseScore = 100;
        _instantReplayBaseScore = -5;
        
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instantReplay)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tap];
    
    self.score = 0;
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
    ChoiceCorrect correct;
    correct = [self logCurrentResponse:button.titleLabel.text];
    [self updateButtonLooks:button forCorrect:correct];
    [self showAnimationFromButton:button forCorrect:correct];
    [_timers addObject:[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(moveToNextPart) userInfo:nil repeats:NO]];
}

-(void)updateButtonLooks:(UIButton *)button forCorrect:(ChoiceCorrect)correct
{
    if (correct) {
        self.imageView.image = [UIImage imageNamed:@"faceoff-photo-correct.png"];
        [button setBackgroundImage:_buttonImages[@"correct"] forState:UIControlStateNormal];
    } else {
        self.imageView.image = [UIImage imageNamed:@"faceoff-photo-wrong.png"];
        [button setBackgroundImage:_buttonImages[@"incorrect"] forState:UIControlStateNormal];
    }
}

-(void)showAnimationFromButton:(UIButton *)button forCorrect:(ChoiceCorrect)correct
{
    NSArray *images = @[@"points-wrong.png", @"points-correct.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[(correct!=0)]]];
    imageView.center = [self.view convertPoint:button.center fromView:self.drawerView];
        self.view.userInteractionEnabled = NO;
    [self.view addSubview:imageView];
    TPLabel *label = [[TPLabel alloc] initWithFrame:imageView.bounds];
    label.fontSize = 20;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    int scoreDelta = [self getScoreDeltaForChoice:correct];
    label.text = [NSString stringWithFormat:@"%i", scoreDelta];
    
    [imageView addSubview:label];
    [UIView animateWithDuration:1.0 animations:^{
        imageView.center = self.scoreLabel.center;
        imageView.alpha = 0.3;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        self.view.userInteractionEnabled = YES;
        self.score += scoreDelta;
    }];
}

-(int)getScoreDeltaForChoice:(ChoiceCorrect)correct
{
    int scoreDelta = 0;
    switch (correct) {
        case ChoiceCorrectNo:
        {
            scoreDelta += _incorrectBaseScore;
        }
            break;
        case ChoiceCorrectPrimary:
        {
            scoreDelta += _correctBaseScore * _primaryMultiplier * _difficultyMultiplier;
        }
            break;
        case ChoiceCorrectSecondary:
        {
            scoreDelta += _correctBaseScore * _secondaryMultiplier * _difficultyMultiplier;
        }
            break;
        default:
            break;
    }
    scoreDelta += (_instantReplayBaseScore * _instantReplayCount);
    return scoreDelta;
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
        self.primaryMultiplier = [data[@"primary_multiplier"] floatValue];
        self.secondaryMultiplier = [data[@"secondary_multiplier"] floatValue];
        self.difficultyMultiplier = [data[@"difficulty_multiplier"] floatValue];
        
        [self logLevelStartedWithAdditionalData:@{
                                                  @"primary_multiplier":[NSNumber numberWithFloat:self.primaryMultiplier],
                                                  @"secondary_multiplier":[NSNumber numberWithFloat:self.secondaryMultiplier],
                                                  @"difficulty_multiplier":[NSNumber numberWithFloat:self.difficultyMultiplier],
                                                  @"time_to_show":[NSNumber numberWithFloat:self.timeToShow],
                                                  }];
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

-(ChoiceCorrect)logCurrentResponse:(NSString *)choice
{
    ChoiceCorrect correct;
    NSArray *correctString = @[@"incorrect", @"correct"];
//    if (self.isSecondary) {
//        correct = [choice isEqualToString:self.secondary];
//    } else {
//        correct = [choice isEqualToString:self.primary];
//    }
    correct = ChoiceCorrectNo;
    if ([choice isEqualToString:self.secondary]) {
        correct = ChoiceCorrectSecondary;
    } else if ([choice isEqualToString:self.primary]) {
        correct = ChoiceCorrectPrimary;
    }
    NSArray *modes = @[@"", @"primary",@"secondary"];
    NSDictionary *event = @{
                            @"event":correctString[(correct!=0)],
                            @"value":choice,
                            @"type":modes[correct],
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

-(void)setScore:(int)score
{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", score];
}

-(int)score
{
    return _score;
}

@end
