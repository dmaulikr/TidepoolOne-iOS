//
//  TPEIGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPGameViewController.h"
#import "TPEIGame.h"

@interface TPEIGameViewController : TPGameViewController

@property (strong, nonatomic) TPEIGame *gameObject;
@property (weak, nonatomic) IBOutlet TPButton *playButton;

@property (assign, nonatomic) int score;

@end
