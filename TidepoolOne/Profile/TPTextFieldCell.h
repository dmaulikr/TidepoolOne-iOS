//
//  TPTextFieldCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPTextFieldCell;

@protocol TPTextFieldCellDelegate <NSObject>

-(void)textFieldCell:(TPTextFieldCell *)cell wasUpdatedTo:(NSString *)string;

@end


@interface TPTextFieldCell : UITableViewCell

@property (nonatomic, strong) TPTextField *textField;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) id<TPTextFieldCellDelegate> delegate;

-(void)forceTextFieldReturn;

@end
