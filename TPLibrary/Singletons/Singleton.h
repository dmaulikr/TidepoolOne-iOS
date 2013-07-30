//
//  SingletonObject.h
//  JamSnap
//
//  Created by Mayank on 4/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

+ (id)sharedInstance;
+ (void) destroyInstance;
+ (void) destroyAllSingletons;

@end
