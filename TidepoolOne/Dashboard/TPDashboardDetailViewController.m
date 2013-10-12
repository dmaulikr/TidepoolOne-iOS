//
//  TPDashboardDetailViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardDetailViewController.h"

@interface TPDashboardDetailViewController ()

@end

@implementation TPDashboardDetailViewController

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
    self.edgesForExtendedLayout = UIRectEdgeNone;    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
    imgView.frame = self.view.frame;
    [self.view insertSubview:imgView atIndex:0];



    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    //virtual function - no implementation
}

-(void)reset
{
    //virtual function - no implementation
}

@end
