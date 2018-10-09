//
//  OpenCVBridgeSub.h
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridge.hh"

@interface OpenCVBridgeSub : OpenCVBridge

-(void)drawColorODS;

-(void)getColorMean:(double*)red withGreen:(double*)green andBlue:(double*)blue;

@end
