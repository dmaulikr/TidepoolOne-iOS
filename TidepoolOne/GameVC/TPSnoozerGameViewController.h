//
//  TPSnoozerGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGameViewController.h"
#import "TPSnoozerGame.h"

@interface TPSnoozerGameViewController : TPGameViewController

@property (strong, nonatomic) TPSnoozerGame *gameObject;
-(void)currentStageDoneWithEvents:(NSArray *)events;

@end
