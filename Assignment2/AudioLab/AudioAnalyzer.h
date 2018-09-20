//
//  AudioAnalyzer.h
//  AudioLab
//
//  Created by Ranger on 9/19/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioInfo : NSObject
@property (nonatomic) float firstFreq;
@property (nonatomic) float secondFreq;
@property (nonatomic) float firstDecibel;
@property (nonatomic) float secondDecibel;
@property (nonatomic) NSString *planoNoteText;
@property (nonatomic) float planoNoteFreq;
@property (nonatomic) float planoFreq;
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
@end

NS_ASSUME_NONNULL_END
