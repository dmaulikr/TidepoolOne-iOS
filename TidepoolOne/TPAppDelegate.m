//
//  TPAppDelegate.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

NSString *const FBSessionStateChangedNotification =
@"com.TidePool.TidepoolOne:FBSessionStateChangedNotification";

@implementation TPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    BOOL openSessionResult = NO;
    // Set up token strategy, if needed
    if (nil == _tokenCaching) {
        _tokenCaching = [[TPTokenCachingStrategy alloc] init];
        // Hard-code for demo purposes, should be set to
        // a unique value that identifies the user of the app.
        [_tokenCaching setThirdPartySessionId:@"213465780"];
    }
    // Initialize a session object with the tokenCacheStrategy
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:@[@"basic_info", @"publish_actions"]
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:_tokenCaching];
    session.accessTokenData;
    // If showing the login UI, or if a cached token is available,
    // then open the session.
    if (allowLoginUI || session.state == FBSessionStateCreatedTokenLoaded) {
        // For debugging purposes log if cached token was found
        if (session.state == FBSessionStateCreatedTokenLoaded) {
            NSLog(@"Cached token found.");
        }
        // Set the active session
        [FBSession setActiveSession:session];
        // Open the session, but do not use iOS6 system acount login
        // if the caching strategy does not store info locally on the
        // device, otherwise you could use:
        // FBSessionLoginBehaviorUseSystemAccountIfPresent
        [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView
                completionHandler:^(FBSession *session,
                                    FBSessionState state,
                                    NSError *error) {
                    [self sessionStateChanged:session
                                        state:state
                                        error:error];
                }];
        // Return the result - will be set to open immediately from the session
        // open call if a cached token was previously found.
        openSessionResult = session.isOpen;
    }
    return openSessionResult;
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end