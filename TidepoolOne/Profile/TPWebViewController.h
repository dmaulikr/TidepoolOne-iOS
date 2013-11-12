//
//  TPWebViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/8/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;
@end
