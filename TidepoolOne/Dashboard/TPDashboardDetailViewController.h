//
//  TPDashboardDetailViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDashboardWidgetViewController.h"

@interface TPDashboardDetailViewController : UIViewController

@property (nonatomic, strong) TPDashboardDetailViewController *widget;

-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
;
-(void)reset;

@end
