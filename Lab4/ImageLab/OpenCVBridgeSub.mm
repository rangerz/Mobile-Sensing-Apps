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
#define BUFFER_SIZE 200

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
    cv::Mat image_rgb;
    cv::Mat image = self.image;
    cv::Mat image_HSV;
    cvtColor(image, image_rgb, CV_RGBA2RGB); // get rid of alpha for processing
    cvtColor(image_rgb, image_HSV, CV_RGB2HSV); // Get HSV

    Scalar avgPixelIntensity;
    avgPixelIntensity = cv::mean(image_rgb);
    double red = avgPixelIntensity.val[0];
    double green = avgPixelIntensity.val[1];
    double blue = avgPixelIntensity.val[2];
    
    Scalar avgPixelHSV;
    avgPixelHSV = cv::mean(image_HSV);
    double h = avgPixelHSV.val[0];
    double s = avgPixelHSV.val[1];
    double v = avgPixelHSV.val[2];

    char text[50];
    sprintf(text,"Avg. R: %3.2f", red);
    cv::putText(image, text, cv::Point(80, 60), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    sprintf(text,"Avg. G: %3.2f", green);
    cv::putText(image, text, cv::Point(80, 70), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    sprintf(text,"Avg. B: %3.2f", blue);
    cv::putText(image, text, cv::Point(80, 80), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    self.image = image;
    
    sprintf(text,"Avg. H: %3.2f", h);
    cv::putText(image, text, cv::Point(80, 90), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    sprintf(text,"Avg. S: %3.2f", s);
    cv::putText(image, text, cv::Point(80, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    sprintf(text,"Avg. V: %3.2f", v);
    cv::putText(image, text, cv::Point(80, 110), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    
}

-(void)getColorMean:(float*)red withGreen:(float*)green andBlue:(float*)blue{
    cv::Mat image_copy;
    cv::Mat image = self.image;
    cvtColor(image, image_copy, CV_RGBA2RGB); // get rid of alpha for processing

    Scalar avgPixelIntensity;
    Scalar avgPixelHSV;
    avgPixelIntensity = cv::mean( image_copy );

    *red = avgPixelIntensity.val[0];
    *green = avgPixelIntensity.val[1];
    *blue = avgPixelIntensity.val[2];
}

@end
