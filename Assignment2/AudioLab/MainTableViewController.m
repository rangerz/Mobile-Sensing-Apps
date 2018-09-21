//
//  MainTableViewController.m
//  AudioLab
//
//  Created by Ranger on 9/13/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "MainTableViewController.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *className = @"";
    NSString *label = @"";
    if (0 == indexPath.section) {
        className = @"Module A";
        label = @"Module A: Loudest Freq. & Plano Note";
    } else if (1 == indexPath.section) {
        className = @"Module B";
        label = @"Module B: Hearing Test & Doppler Effect";
    } else {
        className = @"Exceptional";
        label = @"Exceptional: Basketball Dribbling";
    }

    cell = [tableView dequeueReusableCellWithIdentifier:className forIndexPath:indexPath];
    cell.textLabel.text = label;

    return cell;
}

@end
