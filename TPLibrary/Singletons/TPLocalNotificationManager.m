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


-(void)refreshDayOfTheWeekNotificationsForGame:(NSString *)gameName withActualTimes:(NSSet *)playedHours
{
    [self deleteNotificationsForGame:gameName];
    [self createDayOfTheWeekNotificationsForGame:gameName withActualTimes:playedHours];
}


-(void)refreshHourOfTheDayNotificationsForGame:(NSString *)gameName withActualTimes:(NSSet *)playedHours
{
    [self deleteNotificationsForGame:gameName];
    [self createHourOfTheDayNotificationsForGame:gameName withActualTimes:playedHours];
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


-(void)createHourOfTheDayNotificationsForGame:(NSString *)gameName withActualTimes:(NSSet *)playedHours
{
    NSMutableSet *idealTimesSet = [NSMutableSet setWithArray:@[@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20"]];
    [idealTimesSet minusSet:playedHours];
    int numChoicesNeeded = (3 < idealTimesSet.count) ? 3 : idealTimesSet.count;
    
    for (int i=0; i<numChoicesNeeded; i++) {
        NSString *choice = [idealTimesSet anyObject];
        [idealTimesSet removeObject:choice];
        
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

-(void)createDayOfTheWeekNotificationsForGame:(NSString *)gameName withActualTimes:(NSSet *)playedDays
{
    NSMutableSet *idealDaysSet = [NSMutableSet setWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",]];
    [idealDaysSet minusSet:playedDays];
    int numChoicesNeeded = (3 < idealDaysSet.count) ? 3 : idealDaysSet.count;
    
    for (int i=0; i<numChoicesNeeded; i++) {
        NSString *choice = [idealDaysSet anyObject];
        [idealDaysSet removeObject:choice];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = [self noonForDayOfTheWeek:[choice intValue]];
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

-(NSDate *)noonForDayOfTheWeek:(int)targetWeekday
{
    NSDate *referenceDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit | NSWeekCalendarUnit |NSWeekdayCalendarUnit|NSDayCalendarUnit) fromDate:referenceDate];
    if (dateComponents.weekday >= targetWeekday) {
        dateComponents.week++;
    }
    dateComponents.weekday = targetWeekday;
    return [calendar dateFromComponents:dateComponents];
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


-(void)refreshNotificationsForUser:(TPUser *)user
{
    //refresh notifications for all games
    NSDictionary *resultToGame = @{
                                   @"SpeedAggregateResult": @"snoozer",
                                   @"AttentionAggregateResult": @"echo",
                                   @"EmoAggregateResult": @"faceoff",
                                   };
    for (NSDictionary *aggregateResult in user.aggregateResults) {
        NSString *game = resultToGame[aggregateResult[@"type"]];
        if (game) {
            // hour of the day
            NSDictionary *circadian = aggregateResult[@"scores"][@"circadian"];
            NSMutableSet *playedHours = [NSMutableSet set];
            if (circadian) {
                for (NSDictionary *key in circadian) {
                    if (![circadian[key][@"times_played"] isEqualToNumber:@0]) {
                        [playedHours addObject:key];
                    }
                }
                [self refreshHourOfTheDayNotificationsForGame:game withActualTimes:playedHours];
            }
            
            // day of the week
            NSArray *weekly = aggregateResult[@"scores"][@"weekly"];
            NSMutableSet *playedDays = [NSMutableSet set];
            if (weekly) {
                int dayCount = 0;
                for (NSDictionary *day in weekly) {
                    if ([day[@"data_points"] isEqual:@0]) {
                        [playedDays addObject:[NSString stringWithFormat:@"%i", dayCount]];
                        dayCount++;
                    }
                }
                [self createDayOfTheWeekNotificationsForGame:game withActualTimes:playedDays];
            }
        }
    }
    NSLog([[[UIApplication sharedApplication] scheduledLocalNotifications] description]);
}

@end
