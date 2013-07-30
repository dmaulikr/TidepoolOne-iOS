//
//  SingletonObject.m
//  JamSnap
//
//  Created by Mayank on 4/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

static NSMutableDictionary* instances = nil;

+ (id)sharedInstance
{
	if (!instances) {
		instances = [[NSMutableDictionary alloc] init];
	}
	id instance = [instances objectForKey:self];
	if (!instance) {
		instance = [[self alloc] init];
		[instances setObject:instance forKey:self];
	}
	return instance;
}

+ (void) destroyInstance
{
	[instances removeObjectForKey:self];
}

+ (void) destroyAllSingletons
{
	[instances removeAllObjects];
}

@end