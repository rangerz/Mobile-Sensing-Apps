//
//  MapModel.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "MapModel.h"

@interface MapModel()

@property (strong, nonatomic) NSMutableArray* maps;

@end

@implementation MapModel

-(NSMutableArray*)maps{
    if (!_maps) {
        _maps = [[NSMutableArray alloc] init];
        [_maps addObject:@{@"name": @"China", @"latitude": @"34.4160627", @"longitude": @"86.0603785", @"images": @[@"china1", @"china2", @"china3"], @"currencyName": @"Chinese Yuan", @"currencyShortName": @"CNY", @"dollarPrice": @0.15}];
        [_maps addObject:@{@"name": @"Taiwan", @"latitude": @"23.4696876", @"longitude": @"117.8402375", @"images": @[@"taiwan1", @"taiwan2", @"taiwan3"], @"currencyName": @"Taiwan Dollar", @"currencyShortName": @"TWD", @"dollarPrice": @0.033}];
        [_maps addObject:@{@"name": @"Mexico", @"latitude": @"23.2936843", @"longitude": @"-111.6462031", @"images": @[@"mexico1", @"mexico2", @"mexico3"], @"currencyName": @"Mexican Peso", @"currencyShortName": @"MXN", @"dollarPrice": @0.052}];
    }
    return _maps;
}

+(MapModel*)sharedInstance{
    static MapModel * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[MapModel alloc] init];
    });
    
    return _sharedInstance;
}

-(NSDictionary*)getMapByIndex:(NSInteger)index{
    return self.maps[index];
}

-(NSInteger)getMapCount{
    return [self.maps count];
}

-(NSArray*)getMaps{
    return self.maps;
}

@end

