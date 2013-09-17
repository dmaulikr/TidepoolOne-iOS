//
//  TPServiceLoginViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TPServiceLoginViewControllerDelegate

-(void)connectionMadeSucessfully:(BOOL)success;

@end

@interface TPServiceLoginViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) id<TPServiceLoginViewControllerDelegate> delegate;
@end
