//
//  TPGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TPGameViewController : UIViewController

@property NSString *type;

-(void)startNewGame;
-(void)currentStageDone;
-(void)logEvent:(NSDictionary *)event;

@end
