//
//  TPWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/26/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPWidgetViewController.h"

@interface TPWidgetViewController ()
{
    TPOAuthClient *_oauthClient;
}
@end

@implementation TPWidgetViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)retrieveDataFromServer
{
    [_oauthClient getPath:_dataSource parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _data = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error");
    }];
}


@end
