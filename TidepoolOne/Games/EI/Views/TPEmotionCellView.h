//
//  TPEmotionCellView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPEmotionCellView : UICollectionViewCell

-(void)setEmotion:(NSString *)emotion selected:(BOOL)selected;

@property (assign, nonatomic) BOOL isHighlighted;

@end
