//
//  TPDrawerViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/18/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDrawerViewController.h"
#import "TPLeaderboardViewController.h"
#import "TPInviteFriendsViewController.h"

@implementation TPDrawerViewController

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

    [self setCenterPanel:[[TPLeaderboardViewController alloc] init]];
    [self setRightPanel:[[TPInviteFriendsViewController alloc] init] ];
    self.pushesSidePanels = YES;
    self.allowRightSwipe = NO;
    _rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-leader-email.png"] style:UIBarButtonItemStylePlain target:self action:@selector(swipeInRightPanel)];
    [self.navigationItem setRightBarButtonItem:_rightButton];
}

-(void)swipeInRightPanel
{
    [self showRightPanelAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
