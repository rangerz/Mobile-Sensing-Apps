//
//  MainTableViewController.m
//  SMUExample1
//
//  Created by RR on 9/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "MainTableViewController.h"
#import "AppModel.h"
#import "MapTableViewController.h"
#import "CurrencyViewController.h"
#import "TimeDateViewController.h"

@interface MainTableViewController ()
@property (strong, nonatomic) AppModel* appModel;
@end

@implementation MainTableViewController

-(AppModel*)appModel{
    if (!_appModel) {
        _appModel = [AppModel sharedInstance];
    }
    return _appModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.appModel getMainCellCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSInteger index = indexPath.section;
    NSDictionary *mainCell = [self.appModel getMainCell: index];
    NSString *className = mainCell[@"class"];
    NSString *title = mainCell[@"title"];

    cell = [tableView dequeueReusableCellWithIdentifier:className forIndexPath:indexPath];
    cell.textLabel.text = title;

    return cell;
}

@end
