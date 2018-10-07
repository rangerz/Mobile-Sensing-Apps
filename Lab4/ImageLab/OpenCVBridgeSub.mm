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

-(bool)processImage{
    
    cv::Mat frame_gray,image_copy;
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"Avg. R: %.0f, G: %.0f, B: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    cv::putText(image, text, cv::Point(20, 20), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    
    float red = avgPixelIntensity.val[0];
    float green = avgPixelIntensity.val[1];
    float blue = avgPixelIntensity.val[2];
    
    self.image = image;
    bool isCovered = false;

    
    int th = 50;
    if (red > 100) {
        if (((red - th) > green) && ((red - th) > blue)) {
            isCovered = true;
        }
    }
    
    static int count = 0;
    static float redArr[100];
    static float greenArr[100];
    static float blueArr[100];

    if (isCovered) {
        if (count == 100) {
            count++;
            printf("covered 100 times\n");
        } else {
            redArr[count] = red;
            greenArr[count] = green;
            blueArr[count] = blue;
            count++;
        }
    }

    static milliseconds startTime = duration_cast< milliseconds >(system_clock::now().time_since_epoch());
    milliseconds nowTime = duration_cast< milliseconds >(system_clock::now().time_since_epoch());
    if (count == 1) {
        startTime = duration_cast< milliseconds >(system_clock::now().time_since_epoch());
    } else if (count == 100) {
        if (startTime != nowTime) {
            printf("100 points float array for %lld ms\n", (nowTime - startTime));
        }
    }

    return isCovered;
}

@end
