//
//  AppModel.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "AppModel.h"

@interface AppModel()

@property (strong, nonatomic) NSMutableArray* countryData;
@property (strong, nonatomic) NSMutableArray* mainCells;

@end

@implementation AppModel

+(AppModel*)sharedInstance{
    static AppModel * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[AppModel alloc] init];
    });

    return _sharedInstance;
}

-(NSMutableArray*)mainCells{
    if (!_mainCells) {
        _mainCells = [[NSMutableArray alloc] init];
        [_mainCells addObject:@{@"title": @"Map", @"class": @"MapTableCell"}];
        [_mainCells addObject:@{@"title": @"Currency Converter", @"class": @"CurrencyCell"}];
        [_mainCells addObject:@{@"title": @"Time and Date", @"class": @"TimeDateCell"}];
    }

    return _mainCells;
}

-(NSInteger)getMainCellCount {
    return [self.mainCells count];
}

-(NSDictionary*)getMainCell: (NSInteger)index {
    return [self.mainCells objectAtIndex:index];
}

-(NSMutableArray*)countryData{
    if (!_countryData) {
        _countryData = [[NSMutableArray alloc] init];
        [_countryData addObject:@{
                                  @"name": @"China",
                                  @"latitude": @"34.4160627",
                                  @"longitude": @"86.0603785",
                                  @"images": @[@"china1", @"china2", @"china3"],
                                  @"currencyName": @"Chinese Yuan",
                                  @"currencyShortName": @"CNY",
                                  @"dollarPrice": @0.15,
                                  @"timezone": @"GMT+0800"
                                  }];
        [_countryData addObject:@{
                                  @"name": @"Taiwan",
                                  @"latitude": @"23.4696876",
                                  @"longitude": @"117.8402375",
                                  @"images": @[@"taiwan1", @"taiwan2", @"taiwan3"],
                                  @"currencyName": @"Taiwan Dollar",
                                  @"currencyShortName": @"TWD",
                                  @"dollarPrice": @0.033,
                                  @"timezone": @"GMT+0800"
                                  }];
        [_countryData addObject:@{
                                  @"name": @"Mexico",
                                  @"latitude": @"23.2936843",
                                  @"longitude": @"-111.6462031",
                                  @"images": @[@"mexico1", @"mexico2", @"mexico3"],
                                  @"currencyName": @"Mexican Peso",
                                  @"currencyShortName": @"MXN",
                                  @"dollarPrice": @0.052,
                                  @"timezone": @"CDT"
                                  }];
    }
    return _countryData;
}

-(NSInteger)getCountryCount {
    return [self.countryData count];
}

-(NSDictionary*)getCountryData: (NSInteger)index {
    return [self.countryData objectAtIndex:index];
}

@end

