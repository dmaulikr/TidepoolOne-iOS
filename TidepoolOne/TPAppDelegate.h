//
//  TPAppDelegate.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPTokenCachingStrategy.h"
#import <FacebookSDK/FacebookSDK.h>

@interface TPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) TPTokenCachingStrategy *tokenCaching;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI completionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
- (void) closeSession;


@end
