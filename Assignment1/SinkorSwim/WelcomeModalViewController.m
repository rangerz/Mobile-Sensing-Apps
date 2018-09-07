//
//  WelcomeModalViewController.m
//  SMUExample1
//
//  Created by RR on 9/5/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "WelcomeModalViewController.h"
#import "UIViewController+MaryPopin.h"

@interface WelcomeModalViewController ()
- (IBAction)closeButtonPressed:(id)sender;
@end

@implementation WelcomeModalViewController
- (IBAction)closeButtonPressed:(id)sender {
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{
        NSLog(@"Popin dismissed !");
    }];
}

@end
