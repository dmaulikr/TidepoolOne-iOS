//
//  TPWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/26/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPOAuthClient.h"

@interface TPWidgetViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *dataSourcePath;
@property (nonatomic, strong) TPOAuthClient *oauthClient;

-(void)retrieveDataFromServer;

@end
