//
//  TPOverlayView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPOverlayView : UIView

-(void)setCompletionBlock:(void (^)(void))completionBlock;

@end
