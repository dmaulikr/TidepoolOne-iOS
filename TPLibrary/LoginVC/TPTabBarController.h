//
//  TPTabBarController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPPersonalityGameViewController.h"

@interface TPTabBarController : UITabBarController<TPPersonalityGameViewControllerDelegate>

-(void)personalityGameIsDone:(id)sender;
-(void)showPersonalityGame;

@end
