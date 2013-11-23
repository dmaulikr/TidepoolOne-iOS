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

-(void)refreshNotificationsForGame:(NSString *)gameName
{
    NSLog([[[UIApplication sharedApplication] scheduledLocalNotifications] description]);
    [self deleteNotificationsForGame:gameName];
    NSLog([[[UIApplication sharedApplication] scheduledLocalNotifications] description]);
    NSLog(@"---");
    [self createNotificationsForGame:gameName];
    NSLog([[[UIApplication sharedApplication] scheduledLocalNotifications] description]);
}

-(void)deleteNotificationsForGame:(NSString *)gameName
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i=0; i<notifications.count; i++) {
        UILocalNotification *notification = notifications[i];
        NSDictionary *userInfo = notification.userInfo;
        if ([userInfo[@"game"] isEqualToString:gameName]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}


-(void)createNotificationsForGame:(NSString *)gameName
{
    
    NSArray *idealTimes = @[@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20];
    NSArray *actualTimes = @[@4,@10,@12,@19];
    
    NSMutableSet *possibleTimesToNotify = [NSMutableSet setWithArray:idealTimes];
    [possibleTimesToNotify intersectSet:[NSSet setWithArray:actualTimes]];
    
    int numChoicesNeeded = 3;
    for (int i=0; i<numChoicesNeeded; i++) {
        NSNumber *choice = [possibleTimesToNotify anyObject];
        [possibleTimesToNotify removeObject:choice];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = [self dateAtHour:[choice intValue] daysInFuture:(i+1)];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotif.alertBody = [NSString stringWithFormat:@"Play %@ to track your brain speed and attention", gameName];
        localNotif.alertAction = @"Play Now";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        
        NSDictionary *infoDict = @{
                                   @"action":@"play",
                                   @"game":gameName,
                                   };
        localNotif.userInfo = infoDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}


-(NSDate *)dateAtHour:(int)hour daysInFuture:(int)days
{
    NSDate *today = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    NSDate *tomorrow = [gregorian dateByAddingComponents:components toDate:today options:0];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    components = [gregorian components:unitFlags fromDate:tomorrow];
    components.hour = hour;
    components.minute = 0;
    
    return [gregorian dateFromComponents:components];
}



@end
