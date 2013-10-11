//
//  TPGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPGame.h"

@interface TPGameViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) TPGame *gameObject;
@property NSString *type;
@property (assign) int stage;
@property (assign) int gameScore;
@property (weak, nonatomic) IBOutlet UIView *gameStartView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

-(void)currentStageDoneWithEvents:(NSArray *)events;
-(void)logEvent:(NSDictionary *)event;
-(void)getNewGame;
-(void)getResults;

- (void) displayContentController: (UIViewController*) content;
- (void) hideContentController: (UIViewController*) content;


@end
