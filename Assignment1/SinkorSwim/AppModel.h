//
//  AppModel.h
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppModel : NSObject

+(AppModel*) sharedInstance;

-(NSInteger)getMainCellCount;
-(NSDictionary*)getMainCell: (NSInteger)index;
-(NSInteger)getCountryCount;
-(NSDictionary*)getCountryData: (NSInteger)index;

@end
