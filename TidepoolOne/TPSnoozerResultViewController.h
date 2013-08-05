//
//  TPSnoozerResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLabel.h"

@interface TPSnoozerResultViewController : UIViewController

@property (nonatomic, strong) NSNumber *currentFastestTime;
@property (nonatomic, strong) NSNumber *numberCorrect;
@property (nonatomic, strong) NSNumber *numberWrong;
@property (nonatomic, strong) NSArray *history;
@end
