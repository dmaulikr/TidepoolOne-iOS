//
//  TPReactionTimeStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPReactionTimeStageCircleView.h"
#import "TPStageViewController.h"

@interface TPReactionTimeStageViewController : TPStageViewController <TPReactionTimeStageCircleViewDelegateProtocol>

-(void)circleViewWasTapped;

@end
