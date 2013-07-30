//
//  TPStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/30/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPGameViewController.h"

@interface TPStageViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) TPGameViewController *gameVC;

@end
