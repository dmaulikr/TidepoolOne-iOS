//
//  TPSnoozerResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultViewController.h"
#import "TPSnoozerHistoryView.h"

@interface TPSnoozerResultViewController ()

@end

@implementation TPSnoozerResultViewController

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
    self.title = @"Snoozer Results";
    self.history = @[@220, @270, @230, @250];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"results-bg.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    float kPadding = 5;
    float kH1Size = 30;
    float kH2Size = 20;
    float kMainResultHeight = 100;
    CGRect bounds = self.view.bounds;
    return;
    NSArray *labels = @[@"FASTEST",[NSString stringWithFormat:@"PERSONAL BEST: %@MS", @234],[NSString stringWithFormat:@"AVG MAN: %@MS", @234],[NSString stringWithFormat:@"AVG WOMAN: %@MS", @234],[NSString stringWithFormat:@"%@", self.currentFastestTime],@"MILLISECONDS",@"HITS & MISSES",[NSString stringWithFormat:@"%@ alarms", self.numberCorrect],[NSString stringWithFormat:@"%@ alarms", self.numberWrong],@"HISTORY",@"TIME"];
    float fontSizes[] = {20,13,13,13,70,20,20,20,20,20,15};
    NSArray *textColors = @[[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],];
    CGRect rects[] = {CGRectMake(kPadding, 0,bounds.size.width/2.0, kH1Size),CGRectMake(kPadding, kH1Size, bounds.size.width/2.0, kH2Size),CGRectMake(bounds.size.width/2.0, 0, bounds.size.width/2.0 - kPadding, kH2Size),CGRectMake(bounds.size.width/2.0, kH2Size, bounds.size.width/2.0 - kPadding, kH2Size),CGRectMake(0, kH1Size + kH2Size, bounds.size.width, kMainResultHeight),CGRectMake(0, kH1Size + kH2Size +kMainResultHeight, bounds.size.width, kH2Size),CGRectMake(0, kH1Size + kH2Size +kMainResultHeight + kH2Size, bounds.size.width/2, kH2Size),CGRectMake(0, kH1Size + kH2Size +kMainResultHeight + kH2Size + kH2Size, bounds.size.width/2, kH2Size),CGRectMake(bounds.size.width/2, kH1Size + kH2Size +kMainResultHeight + kH2Size + kH2Size, bounds.size.width/2, kH2Size),CGRectMake(kPadding, kH1Size + kH2Size +kMainResultHeight + kH2Size + kH2Size + kH2Size, bounds.size.width/2, kH2Size),CGRectMake(0, bounds.size.height-50, bounds.size.width, 50),};
    NSTextAlignment textAlignments[] = {NSTextAlignmentLeft, NSTextAlignmentLeft, NSTextAlignmentRight,NSTextAlignmentRight,NSTextAlignmentCenter,NSTextAlignmentCenter,NSTextAlignmentCenter,NSTextAlignmentLeft,NSTextAlignmentLeft,NSTextAlignmentLeft,NSTextAlignmentCenter, };

    
    for (int i=0;i<labels.count;i++) {
        TPLabel *label = [[TPLabel alloc] initWithFrame:rects[i]];
        label.fontSize = fontSizes[i];
        label.textColor = textColors[i];
        label.text = labels[i];
        label.textAlignment = textAlignments[i];
        [self.view addSubview:label];
    }
    
    TPSnoozerHistoryView *historyView = [[TPSnoozerHistoryView alloc] initWithFrame:CGRectMake(kPadding, 250, bounds.size.width - 2 * kPadding, 150)];
    [self.view addSubview:historyView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
