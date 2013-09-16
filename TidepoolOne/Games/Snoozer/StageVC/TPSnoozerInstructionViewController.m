//
//  TPSnoozerInstructionViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerInstructionViewController.h"
#import "TPSnoozerStageViewController.h"

@interface TPSnoozerInstructionViewController ()

@end

@implementation TPSnoozerInstructionViewController

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
    [self.startButton addTarget:(TPSnoozerStageViewController *)self.stageVC action:@selector(instructionDone) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:[NSString stringWithFormat:@"Snoozer Instruction Screen %@", self.levelNumberLabel.text]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
