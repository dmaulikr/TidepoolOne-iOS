//
//  TPReactionTimeStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPReactionTimeStageCircleView.h"
#import "TPGameViewController.h"

@interface TPReactionTimeStageViewController : UIViewController <TPReactionTimeStageCircleViewDelegateProtocol>

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) TPGameViewController *gameVC;

-(void)circleViewWasTapped;

@end
