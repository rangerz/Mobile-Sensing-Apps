//
//  MainViewController.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/31/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "MainViewController.h"
#import "MapModel.h"
#import "MapTableViewController.h"
#import "CurrencyViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) MapModel* myMapModel;

@end

@implementation MainViewController

-(MapModel*)myMapModel{
    
    if(!_myMapModel)
        _myMapModel = [MapModel sharedInstance];
    
    return _myMapModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
