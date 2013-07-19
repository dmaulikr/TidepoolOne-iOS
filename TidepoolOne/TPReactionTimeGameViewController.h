//
//  TPReactionTimeGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPReactionTimeGameCircleView.h"

@interface TPReactionTimeGameViewController : UIViewController <TPReactionTimeGameCircleViewDelegateProtocol>

@property NSDictionary *response;

-(void)setupGameWithDefinitions:(NSDictionary *)dictionary;
-(void)circleViewWasTapped;

@end
