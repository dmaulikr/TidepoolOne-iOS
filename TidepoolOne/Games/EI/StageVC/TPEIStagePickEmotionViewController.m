//
//  TPEIStagePickEmotionViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIStagePickEmotionViewController.h"

@interface TPEIStagePickEmotionViewController ()

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
    // Do any additional setup after loading the view from its nib.
    [self.emo_1 addTarget:self action:@selector(emotionChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.emo_2 addTarget:self action:@selector(emotionChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.emo_3 addTarget:self action:@selector(emotionChosen:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:[NSString stringWithFormat:@"EI Stage Screen, %i",self.gameVC.stage]];
    self.imageView.image = [UIImage imageNamed:@"btn-red.png"];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(flipImage) userInfo:nil repeats:NO];
}

-(void)flipImage
{
    [UIView transitionWithView:self.imageView
                      duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.imageView.image = [UIImage imageNamed:@"btn-blue.png"];;
                    } completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)emotionChosen:(id)sender
{
    [super stageOver];
}

@end
