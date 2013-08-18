//
//  TPResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/30/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPGameViewController.h"

@interface TPResultViewController : UIViewController

@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, weak) TPGameViewController *gameVC;
@property (weak,nonatomic) UIButton *playAgainButton;
@property (weak,nonatomic) UIButton *learnMoreButton;
@end
