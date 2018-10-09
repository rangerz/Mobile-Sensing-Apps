//
//  OpenCVBridgeSub.m
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeSub.h"

#import "AVFoundation/AVFoundation.h"
#include <chrono>

using namespace cv;
using namespace std::chrono;

@interface OpenCVBridgeSub()
@property (nonatomic) cv::Mat image;
@end

@implementation OpenCVBridgeSub
@dynamic image;
//@dynamic just tells the compiler that the getter and setter methods are implemented not by the class itself but somewhere else (like the superclass or will be provided at runtime).

// For Debug
-(void)drawColorODS{
    cv::Mat image_copy;
    cv::Mat image = self.image;
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing

    Scalar avgPixelIntensity;
    avgPixelIntensity = cv::mean( image_copy );
    double red = avgPixelIntensity.val[0];
    double green = avgPixelIntensity.val[1];
    double blue = avgPixelIntensity.val[2];

    char text[50];
    sprintf(text,"Avg. R: %3.2f", red);
    cv::putText(image, text, cv::Point(20, 60), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    sprintf(text,"Avg. G: %3.2f", green);
    cv::putText(image, text, cv::Point(20, 70), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    sprintf(text,"Avg. B: %3.2f", blue);
    cv::putText(image, text, cv::Point(20, 80), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    self.image = image;
}

-(void)getColorMean:(double*)red withGreen:(double*)green andBlue:(double*)blue{
    cv::Mat image_copy;
    cv::Mat image = self.image;
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing

    Scalar avgPixelIntensity;
    avgPixelIntensity = cv::mean( image_copy );

    *red = avgPixelIntensity.val[0];
    *green = avgPixelIntensity.val[1];
    *blue = avgPixelIntensity.val[2];
}

@end
