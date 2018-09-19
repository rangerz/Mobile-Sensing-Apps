//
//  AudioAnalyzer.m
//  AudioLab
//
//  Created by Ranger on 9/19/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "AudioAnalyzer.h"
#import "CircularBuffer.h"
#import "Novocaine.h"
#import "FFTHelper.h"
#import "PeakFinder.h"

#define BUFFER_SIZE 2048*4

@interface AudioAnalyzer ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) PeakFinder *peakFinder;
@property (strong, nonatomic) NSDictionary *planoNoteMap;
@end

@implementation AudioAnalyzer

@end
