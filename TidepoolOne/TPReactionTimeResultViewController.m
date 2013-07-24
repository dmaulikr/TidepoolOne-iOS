//
//  TPReactionTimeResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeResultViewController.h"
#import "TPGameViewController.h"

@interface TPReactionTimeResultViewController ()

@end

@implementation TPReactionTimeResultViewController

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
    self.minimum.text = self.result[@"score"][@"fastest_time"];
    self.maximum.text = self.result[@"score"][@"slowest_time"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playAgainAction:(id)sender {
    TPGameViewController *gameVC = self.parentViewController;
    [gameVC startNewGame];
}
@end
