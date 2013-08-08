//
//  TPProfileViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPProfileViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *personalityType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;
@property (strong, nonatomic) NSArray *bulletPoints;
@property (strong, nonatomic) NSArray *paragraphs;

@end
