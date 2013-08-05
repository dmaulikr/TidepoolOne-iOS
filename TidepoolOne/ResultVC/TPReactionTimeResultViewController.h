//
//  TPReactionTimeResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPResultViewController.h"

@interface TPReactionTimeResultViewController : TPResultViewController

@property (weak, nonatomic) IBOutlet UITextField *minimum;
@property (weak, nonatomic) IBOutlet UITextField *maximum;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;

@end
