//
//  TPTextFieldCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPTextFieldCell.h"

@interface TPTextFieldCell() <UITextFieldDelegate>
{
    
}
@end

@implementation TPTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _textField = [[TPTextField alloc] initWithFrame:CGRectZero];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.textColor = [UIColor blackColor];
        _textField.delegate = self;
        [self.contentView addSubview:_textField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    if (_title) {
        self.textField.placeholder = title;
    }
}


#pragma mark Laying out subviews

- (void)layoutSubviews {
    _textField.frame = CGRectOffset(self.bounds, 10, 0);
}

-(void)forceTextFieldReturn
{
    [self textFieldShouldReturn:_textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(textFieldCell:wasUpdatedTo:)]) {
        [self.delegate textFieldCell:self wasUpdatedTo:textField.text];
    }
    return YES;
}

@end
