//
//  TPDeepLinkManager.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "Singleton.h"


@interface TPDeepLinkManager : Singleton

@property (nonatomic, strong) UIWindow *appWindow;

-(BOOL)handleUrl:(NSURL *)url;

@end
