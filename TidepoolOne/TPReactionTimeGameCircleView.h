//
//  TPReactionTimeGameCircleView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TPReactionTimeGameCircleView : UIView

-(void)circleTouched;

@property (nonatomic, strong) NSMutableArray *sequence;

@end
