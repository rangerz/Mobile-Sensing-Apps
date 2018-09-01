//
//  MapModel.h
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapModel : NSObject

+(MapModel*) sharedInstance;

-(NSDictionary*)getMapByIndex:(NSInteger)index;
-(NSInteger)getMapCount;
-(NSArray*)getMaps;

@end
