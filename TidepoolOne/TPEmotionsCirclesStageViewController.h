//
//  TPEmotionsCirclesStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPGameViewController.h"
#import "TPCirclesDistanceView.h"

@interface TPEmotionsCirclesStageViewController : UIViewController <TPCirclesDistanceViewDelegate>

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) TPGameViewController *gameVC;
@property (nonatomic, strong) NSMutableArray *circles;
- (IBAction)doneButtonPressed:(id)sender;

-(bool)shouldAllowMoveCircle;
-(void)moveCircle:(TPCirclesDistanceView *)circle toPoint:(CGPoint)point;

@end
