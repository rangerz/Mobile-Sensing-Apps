//
//  AudioAnalyzer.h
//  AudioLab
//
//  Created by Ranger on 9/19/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, DopplerState) {
    DS_Still  = 0,
    DS_Towards = 1 << 0,
    DS_Away = 1 << 2
};

@interface AudioInfo : NSObject
@property (nonatomic) float firstFreq;
@property (nonatomic) float secondFreq;
@property (nonatomic) float firstDecibel;
@property (nonatomic) float secondDecibel;
@property (nonatomic) NSString *pianoNoteText;
@property (nonatomic) float pianoNoteFreq;
@property (nonatomic) float pianoFreq;
@end

@interface AudioAnalyzer : NSObject
-(id)initWithSize:(NSUInteger)size;
-(void)start;
-(void)start:(float)frequency;
-(void)stop;
-(void)fetchData:(float*)data
      withLength:(SInt64)length
         withFft:(float*)fft;

-(void)analyzeAudio:(float*)fft
       forAudioInfo:(AudioInfo*)audioInfo;

-(void)updateFrequencyInKhz:(float) freqInKHz;
-(void)fetchData:(float *)data
      withLength:(SInt64)length
         withFft:(float *)fft
          inZoom:(int)zoom
        withZoom:(float *)fftZoom;
-(DopplerState)analyzeDoppler:(float*)fft
                      withLen:(SInt64)length;
@end

NS_ASSUME_NONNULL_END
