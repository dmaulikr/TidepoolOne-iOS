//
//  TPPersonalityGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TPPersonalityGameViewControllerDelegate

-(void)personalityGameIsDone:(id)sender successfully:(BOOL)success;

@end

@interface TPPersonalityGameViewController : UIViewController

@property (nonatomic, weak) id<TPPersonalityGameViewControllerDelegate> delegate;

@end
