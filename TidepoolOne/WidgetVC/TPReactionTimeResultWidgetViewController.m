//
//  TPReactionTimeResultWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/26/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeResultWidgetViewController.h"

@interface TPReactionTimeResultWidgetViewController ()
@end

@implementation TPReactionTimeResultWidgetViewController

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
    self.oauthClient = [TPOAuthClient sharedClient];
    self.dataSourcePath = @"api/v1/users/-/results?type=ReactionTimeResult";
    [self retrieveDataFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
