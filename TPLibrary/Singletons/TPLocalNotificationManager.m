//
//  TPLocalNotificationManager.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/25/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLocalNotificationManager.h"

@implementation TPLocalNotificationManager

-(void)handleNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSLog(@"Message recd");
}

-(void)createNotification
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:86400]; // 24 hours
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Play Snoozer to track your brain speed and attention", nil)];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"Play" forKey:@"Action"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

@end
