//
//  TPDeepLinkManager.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDeepLinkManager.h"
#import "TPUserProfileViewController.h"

@implementation TPDeepLinkManager

-(NSDictionary *)deepLinkPatterns{
    return @{
             @"//user/(\\w+)/" : @"openUser:",
             @"//user/(\\w+)" : @"openUser:",
             };
}

-(BOOL)handleUrl:(NSURL *)url
{
    NSString *linkString = [url resourceSpecifier];
    NSError *error = NULL;
    for (NSString *pattern in [[self deepLinkPatterns] allKeys]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSTextCheckingResult *result = [regex firstMatchInString:linkString options:NSMatchingAnchored
                                                           range:NSMakeRange(0, linkString.length)];
        
        if (result) {
            NSMutableArray *captures = [NSMutableArray array];
            for (int i=1; i < result.numberOfRanges; i++) {
                NSRange range = [result rangeAtIndex:i];
                NSString *capture = [linkString substringWithRange:range];
                [captures addObject:capture];
            }
            
            NSString *selector = [[self deepLinkPatterns] objectForKey:pattern];
            [self performSelector:NSSelectorFromString(selector) withObject:captures];
            return YES;
        }
    }
    return NO;
}

-(void)openUser:(NSArray *)users
{
    NSString *userId = [users objectAtIndex:0];
    TPUserProfileViewController *vc = [[TPUserProfileViewController alloc] init];
    vc.userId = userId;
    UITabBarController *rootViewController = (UITabBarController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    rootViewController.selectedIndex = 2;
    UINavigationController *navController = [rootViewController.childViewControllers objectAtIndex:2];
    [navController pushViewController:vc animated:YES];
}

@end
