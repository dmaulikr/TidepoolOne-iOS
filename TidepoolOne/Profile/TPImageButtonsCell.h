//
//  TPImageButtonsCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPImageButtonsCell;

@protocol TPImageButtonsCellDelegate <NSObject>

-(void)buttonWasChosenWithIndex:(int)index selected:(BOOL)selected inCell:(TPImageButtonsCell *)cell;
-(void)valueWasChosen:(NSString *)value inCell:(TPImageButtonsCell *)cell;

@end

@interface TPImageButtonsCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *buttonImages;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSString *currentValue;
@property (nonatomic, nonatomic) BOOL exclusiveSelect;
@property (nonatomic, weak) id<TPImageButtonsCellDelegate> delegate;



@end
