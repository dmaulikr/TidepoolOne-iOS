//
//  TPResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/30/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPResultViewController.h"

@interface TPResultViewController ()

@end

@implementation TPResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Results";        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.playAgainButton addTarget:self.gameVC action:@selector(getNewGame) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareGame) forControlEvents:UIControlEventTouchUpInside];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareGame
{
    
}

@end
