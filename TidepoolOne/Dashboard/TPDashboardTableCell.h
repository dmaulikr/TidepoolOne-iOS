//
//  TPDashboardTableCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/8/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPDashboardTableCell : UITableViewCell

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *labels;
@property (strong, nonatomic) NSArray *values;
@property (strong, nonatomic) NSArray *bottomLabels;
@property (strong, nonatomic) NSArray *images;

@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;

@property (strong, nonatomic) TPLabelBold *label1;
@property (strong, nonatomic) TPLabelBold *label2;
@property (strong, nonatomic) TPLabelBold *label3;

@property (strong, nonatomic) TPLabelBold *value1;
@property (strong, nonatomic) TPLabelBold *value2;
@property (strong, nonatomic) TPLabelBold *value3;

@property (strong, nonatomic) TPLabelBold *bottomLabel1;
@property (strong, nonatomic) TPLabelBold *bottomLabel2;
@property (strong, nonatomic) TPLabelBold *bottomLabel3;


@end
