//
//  MapTableViewController.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "MapTableViewController.h"
#import "AppModel.h"
#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MapViewController.h"

@interface MapTableViewController ()
@property(nonatomic, assign) NSInteger index;
@property (strong, nonatomic) AppModel *appModel;
@end

@implementation MapTableViewController

-(AppModel*)appModel {
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.appModel getCountryCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.appModel getCountryData: indexPath.row][@"name"];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[MapViewController class]];
    
    if (isVC){
        MapViewController *vc = [segue destinationViewController];
        [vc setCountryData: [self.appModel getCountryData:[self.tableView indexPathForCell:sender].row]];
    }
}

@end
