//
//  TPSnoozerInstructionViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerInstructionViewController.h"

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
    [self.startButton addTarget:self.stageVC action:@selector(instructionDone) forControlEvents:UIControlEventTouchUpInside];
}
//
//-(void)buttonPressed
//{
////    [UIView beginAnimations:@"curldown" context:nil];
////    [UIView setAnimationDelegate:self];
////    [UIView setAnimationDuration:.5];
////    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
////    [self.view removeFromSuperview];
////    [UIView commitAnimations];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
