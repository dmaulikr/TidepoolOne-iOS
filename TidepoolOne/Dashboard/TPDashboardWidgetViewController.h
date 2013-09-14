//
//  TPDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPDashboardWidgetViewController : UIViewController

-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
;
-(void)reset;

@end
