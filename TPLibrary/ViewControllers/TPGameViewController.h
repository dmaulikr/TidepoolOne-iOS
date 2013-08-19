//
//  TPGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPGameViewController : UIViewController

@property (strong, nonatomic) id gameObject;
@property NSString *type;
@property (assign) int stage;

-(void)currentStageDoneWithEvents:(NSArray *)events;
-(void)logEvent:(NSDictionary *)event;
-(void)getNewGame;
@end
