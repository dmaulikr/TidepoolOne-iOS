//
//  TPSnoozerStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerStageViewController.h"

@interface TPSnoozerStageViewController ()
{
    
}
@end

@implementation TPSnoozerStageViewController

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
	// Do any additional setup after loading the view.
    NSLog([self.data description]);
    self.numRows = 2;
    self.numColumns = 2;
}

- (void)viewDidAppear:(BOOL)animated
{
    int boxHeight = self.view.bounds.size.height / self.numRows;
    int boxWidth = self.view.bounds.size.width / self.numColumns;
    for (int i=0; i<self.numColumns; i++) {
        for (int j=0; j<self.numRows; j++) {
            TPSnoozerClockView *clockView = [[TPSnoozerClockView alloc] initWithFrame:CGRectMake(i*boxWidth, j*boxHeight, boxWidth, boxHeight)];
            clockView.isRinging = YES;
            clockView.delegate = self;
            [self.view addSubview:clockView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clockViewWasTouched:(TPSnoozerClockView *)clockView
{
    [clockView tappedCorrectly:NO];
}


@end
