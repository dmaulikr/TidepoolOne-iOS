//
//  TPDashboardTableCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/8/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardTableCell.h"

@interface TPDashboardTableCell()
{
    UIImageView *_imageView;
    
}
@end


@implementation TPDashboardTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 320, 109)];
        [self addSubview:_imageView];
        
        float labelX = 0;
        float labelY = 30;
        float labelHeight = 50;
        float labelWidth = 320/3;
        
        _label1 = [[TPLabelBold alloc] initWithFrame:CGRectMake(labelX + 0*labelWidth, labelY, labelWidth, labelHeight)];
        _label1.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label1];
        _label2 = [[TPLabelBold alloc] initWithFrame:CGRectMake(labelX + 1*labelWidth, labelY, labelWidth, labelHeight)];
        _label2.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label2];
        _label3 = [[TPLabelBold alloc] initWithFrame:CGRectMake(labelX + 2*labelWidth, labelY, labelWidth, labelHeight)];
        _label3.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label3];

        _label1.fontSize = _label2.fontSize = _label3.fontSize = 10;
        
        float valueX = 0;
        float valueY = 55;
        float valueHeight = 50;
        float valueWidth = 320/3;
        
        _value1 = [[TPLabelBold alloc] initWithFrame:CGRectMake(valueX + 0*valueWidth, valueY, valueWidth, valueHeight)];
        _value1.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_value1];
        _value2 = [[TPLabelBold alloc] initWithFrame:CGRectMake(valueX + 1*valueWidth, valueY, valueWidth, valueHeight)];
        _value2.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_value2];
        _value3 = [[TPLabelBold alloc] initWithFrame:CGRectMake(valueX + 2*valueWidth, valueY, valueWidth, valueHeight)];
        _value3.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_value3];


        _value1.fontSize = _value2.fontSize = _value3.fontSize = 30;

        float imageViewX = 0;
        float imageViewY = 26;
        float imageViewHeight = 106;
        float imageViewWidth = 320/3;
        
        _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX + 0*imageViewWidth, imageViewY, imageViewWidth, imageViewHeight)];
        [self addSubview:_imageView1];
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX + 1*imageViewWidth, imageViewY, imageViewWidth, imageViewHeight)];
        [self addSubview:_imageView2];
        _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX + 2*imageViewWidth, imageViewY, imageViewWidth, imageViewHeight)];
        [self addSubview:_imageView3];
        
        float bottomLabelOffset = 47;
        
        _bottomLabel1 = [[TPLabelBold alloc] initWithFrame:CGRectMake(labelX + 0*labelWidth, labelY + bottomLabelOffset, labelWidth, labelHeight)];
        _label1.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel1];
        _bottomLabel2 = [[TPLabelBold alloc] initWithFrame:CGRectMake(labelX + 1*labelWidth, labelY + bottomLabelOffset, labelWidth, labelHeight)];
        _bottomLabel2.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel2];
        _bottomLabel3 = [[TPLabelBold alloc] initWithFrame:CGRectMake(labelX + 2*labelWidth, labelY + bottomLabelOffset, labelWidth, labelHeight)];
        _bottomLabel3.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel3];
        
        _bottomLabel1.fontSize = _bottomLabel2.fontSize = _bottomLabel3.fontSize = 13;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setName:(NSString *)name
{
    _name = name;
    if (name) {
        _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"dash-%@bg-b.png", name]];
    }
}

-(void)setLabels:(NSArray *)labels
{
    _labels = labels;
    if (labels) {
        _label1.text = labels[0];
        _label2.text = labels[1];
        _label3.text = labels[2];
    }
}

-(void)setValues:(NSArray *)values
{
    _values = values;
    if (values) {
        _value1.text = values[0];
        _value2.text = values[1];
        _value3.text = values[2];
    }
}

-(void)setBottomLabels:(NSArray *)bottomLabels
{
    _bottomLabels = bottomLabels;
    if (bottomLabels) {
        _bottomLabel1.text = bottomLabels[0];
        _bottomLabel2.text = bottomLabels[1];
        _bottomLabel3.text = bottomLabels[2];
    }
}

-(void)setImages:(NSArray *)images
{
    _images = images;
    if (images) {
        _imageView1.image = images[0];
        _imageView2.image = images[1];
        _imageView3.image = images[2];
    }
}

@end
