//
//  TPDashboardDrawerViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 12/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardDrawerViewController.h"
#import "TPDashboardViewController.h"
#import "TPInviteFriendsViewController.h"


@interface TPDashboardDrawerViewController ()

@end

@implementation TPDashboardDrawerViewController

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
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self setCenterPanel:[[TPDashboardViewController alloc] init]];
    [self setRightPanel:[[TPInviteFriendsViewController alloc] init] ];
    self.pushesSidePanels = YES;
    self.allowRightSwipe = YES;
    _rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"activity-ic-bell.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleRightPanel:)];
    [self.navigationItem setRightBarButtonItem:_rightButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
