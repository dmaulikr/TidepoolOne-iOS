//
//  TPAppDelegate.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TPLocalNotificationManager.h"
#import "TPOAuthClient.h"
#import <TestFlightSDK/TestFlight.h>
#import <UAirship.h>
#import <UAConfig.h>
#import <UAPush.h>
#import "TPDeepLinkManager.h"
#import <Crashlytics/Crashlytics.h>
#import <NewRelicAgent/NewRelicAgent.h>

NSString *const FBSessionStateChangedNotification =
@"com.TidePool.TidepoolOne:FBSessionStateChangedNotification";

@implementation TPAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Mixpanel sharedInstanceWithToken:@"d66bffcec658e942b00c61da53593578"];
    [Crashlytics startWithAPIKey:@"9f8541995b58309d5b2b3052d5446a21c880f2eb"];
    [NewRelicAgent startWithApplicationToken:@"AA86d83ce88dfcb6d82cb93963ccb69377c9414111"];
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-43075789-1"];
    
//    [TestFlight takeOff:@"f9c7e27c-d774-4e7b-a6aa-b5f5e9551123"];
    
    //Clear keychain on first run in case of reinstallation
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        // Delete values from keychain here
        [[TPOAuthClient sharedClient] deleteAllPasswords];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
    }
    
    // Handle launching from a notification
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [[TPLocalNotificationManager sharedInstance] handleNotification:localNotification];
    }
    
    [self customizeAppearance];
    
    
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    [UAirship setLogLevel:UALogLevelTrace];
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    [UAPush setDefaultPushEnabledValue:NO];
    [[UAPush shared] resetBadge];
    
    // Set the notification types required for the app (optional). With the default value of push set to no,
    // UAPush will record the desired remote notification types, but not register for
    // push notifications as mentioned above. When push is enabled at a later time, the registration
    // will occur normally. This value defaults to badge, alert and sound, so it's only necessary to
    // set it if you want to add or remove types.
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert);

    return YES;
}

-(void)customizeAppearance
{
    UIFont *font = [UIFont fontWithName:@"Karla-Bold" size:15.0];
    [[UITextView appearance] setFont:font];
    [[UIButton appearance] setFont:font];
    [[UILabel appearanceWhenContainedIn:[UIButton class], nil] setFont:font];
    NSDictionary *barButtonAppearanceDict = @{UITextAttributeFont : [UIFont fontWithName:@"Karla-Regular" size:17.0],UITextAttributeTextColor : [UIColor blackColor],UITextAttributeTextShadowOffset : @0,
                                              };
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"btn-rect2.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor],
          UITextAttributeTextColor,
          [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
          UITextAttributeTextShadowColor,
          [NSValue valueWithUIOffset:UIOffsetMake(0, -0)],
          UITextAttributeTextShadowOffset,
          [UIFont fontWithName:@"Karla-Regular" size:20.0],
          UITextAttributeFont,
          nil]];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"titlebar.png"] forBarMetrics:UIBarMetricsDefault];
    } else {
        // Load resources for iOS 7 or later
        [UINavigationBar appearance].tintColor = [UIColor blackColor];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor],
          UITextAttributeTextColor,
          [UIFont fontWithName:@"Karla-Regular" size:20.0],
          UITextAttributeFont,
          nil]];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[TPLocalNotificationManager sharedInstance] handleNotification:notification];
    
//    UIApplicationState state = [application applicationState];
//    if (state == UIApplicationStateActive) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
//                                                        message:notification.alertBody
//                                                       delegate:self cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
//    
//    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
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
    [FBSession.activeSession handleDidBecomeActive];
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
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI completionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    BOOL openSessionResult = NO;
    // Set up token strategy, if needed
    if (nil == _tokenCaching) {
        _tokenCaching = [[TPTokenCachingStrategy alloc] init];
        // Hard-code for demo purposes, should be set to
        // a unique value that identifies the user of the app.
    }
    // Initialize a session object with the tokenCacheStrategy
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:@[@"basic_info", @"email"]
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:_tokenCaching];
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
                    successBlock();
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
    NSString *urlString = [url absoluteString];
    if ([urlString hasPrefix:@"tidepool:"]) {
        return [[TPDeepLinkManager sharedInstance] handleUrl:url];
    }
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"PushToken"];
}


@end