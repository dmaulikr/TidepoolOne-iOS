//
//  TPLocalNotificationManager.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/25/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "Singleton.h"

@interface TPLocalNotificationManager : Singleton

-(void)handleNotification:(UILocalNotification *)notification;
-(void)refreshNotificationsForUser:(TPUser *)user;

@end
