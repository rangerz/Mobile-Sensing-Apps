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
#import "WelcomeModalViewController.h"
#import "UIViewController+MaryPopin.h"

@interface MainTableViewController ()
@property (strong, nonatomic) AppModel* appModel;
@property (nonatomic, strong) CustomClass* custom;
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
    
    self.custom = [[CustomClass alloc] init];
    self.custom.delegate = self;
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

- (IBAction)pressModalButton:(id)sender {
    [self.custom openModalDelegate];
}

-(void)openModal:(CustomClass *)customClass
{
    WelcomeModalViewController *welcome = [[WelcomeModalViewController alloc] init];
    [welcome setPopinTransitionStyle:BKTPopinTransitionStyleSlide];
    [welcome setPopinOptions:BKTPopinDefault];
    [welcome setPopinAlignment:BKTPopinAlignementOptionCentered];
    
    BKTBlurParameters *blurParameters = [BKTBlurParameters new];
    blurParameters.alpha = 1.0f;
    blurParameters.radius = 8.0f;
    blurParameters.saturationDeltaFactor = 1.8f;
    blurParameters.tintColor = [UIColor colorWithRed:0.966 green:0.851 blue:0.038 alpha:0.2];
    [welcome setBlurParameters:blurParameters];
    [welcome setPopinOptions:[welcome popinOptions]|BKTPopinBlurryDimmingView];
    [welcome setPreferedPopinContentSize:CGSizeMake(320.0, 240.0)];
    [welcome setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    [self.navigationController presentPopinController:welcome animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}

@end
