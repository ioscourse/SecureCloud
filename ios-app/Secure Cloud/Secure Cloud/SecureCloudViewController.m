//
//  SecureCloudViewController.m
//  Secure Cloud
//
//  Created by webstudent on 4/22/13.
//  Copyright (c) 2013 Rock Valley College. All rights reserved.
//

#import "SecureCloudViewController.h"

@interface SecureCloudViewController ()

@end

@implementation SecureCloudViewController

@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *targetURL = [NSURL URLWithString:@"http://192.168.10.109:8080/ios.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    [[webView scrollView] setBounces: NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
