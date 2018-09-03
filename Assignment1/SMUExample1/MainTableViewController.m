//
//  MainTableViewController.m
//  SMUExample1
//
//  Created by RR on 9/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "MainTableViewController.h"
#import "MapModel.h"
#import "MapTableViewController.h"
#import "CurrencyViewController.h"

@interface MainTableViewController ()
@property (strong, nonatomic) MapModel* myMapModel;

@end

@implementation MainTableViewController

-(MapModel*)myMapModel{
    if(!_myMapModel)
        _myMapModel = [MapModel sharedInstance];

    return _myMapModel;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///TODO: data from Model

    UITableViewCell *cell = nil;

    if(indexPath.section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MapTableCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Map for Countries";
    } else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Currency Converter";
    }

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BOOL isMapVC = [[segue destinationViewController] isKindOfClass:[MapTableViewController class]];
    BOOL isCurrencyVC = [[segue destinationViewController] isKindOfClass:[CurrencyViewController class]];

    if(isMapVC){
        MapTableViewController *vc = [segue destinationViewController];
        vc.countries = [self.myMapModel getMaps];
    }

    if(isCurrencyVC){
        CurrencyViewController *vc = [segue destinationViewController];
        vc.countries = [self.myMapModel getMaps];
    }
}

@end
