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

#define WINDOWS_SIZE 20
#define MIN_MAGNITUDE 5
#define MIN_FREQUENCY 100
#define PLANO_NOTE_TOL 10.0
#define PLANO_DIV_ERR 0.1

@implementation AudioInfo

-(id)init{
    if(self = [super init]){
        _firstFreq = 0.0;
        _secondFreq = 0.0;
        _firstDecibel = 0.0;
        _secondDecibel = 0.0;
        _planoNoteText = @"";
        _planoNoteFreq = 0.0;
        _planoFreq = 0.0;
        return self;
    }
    return nil;
}

@end

@interface AudioAnalyzer ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) PeakFinder *peakFinder;
@property (strong, nonatomic) NSDictionary *planoNoteMap;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) NSUInteger bufferSize;

@property (nonatomic) float phaseIncrement;
@property (nonatomic) float frequency;
@end

@implementation AudioAnalyzer

-(id)initWithSize:(NSUInteger)size{
    if(self = [super init]){
        _bufferSize = size;
        return self;
    }
    return nil;
}

-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:(int)_bufferSize];
    }
    
    return _fftHelper;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:_bufferSize];
    }
    return _buffer;
}

-(PeakFinder*)peakFinder{
    if(!_peakFinder){
        _peakFinder = [[PeakFinder alloc]initWithFrequencyResolution:(((float)self.audioManager.samplingRate) / ((float)(_bufferSize)))];
    }
    return _peakFinder;
}

-(NSDictionary*)planoNoteMap{
    if(!_planoNoteMap){
        // A4 = 440 Hz
        _planoNoteMap = @{[NSNumber numberWithFloat:16.35]:@"C0",
                          [NSNumber numberWithFloat:17.32]:@"C#0/Db0",
                          [NSNumber numberWithFloat:18.35]:@"D0",
                          [NSNumber numberWithFloat:19.45]:@"D#0/Eb0",
                          [NSNumber numberWithFloat:20.6]:@"E0",
                          [NSNumber numberWithFloat:21.83]:@"F0",
                          [NSNumber numberWithFloat:23.12]:@"F#0/Gb0",
                          [NSNumber numberWithFloat:24.5]:@"G0",
                          [NSNumber numberWithFloat:25.96]:@"G#0/Ab0",
                          [NSNumber numberWithFloat:27.5]:@"A0",
                          [NSNumber numberWithFloat:29.14]:@"A#0/Bb0",
                          [NSNumber numberWithFloat:30.87]:@"B0",
                          [NSNumber numberWithFloat:32.7]:@"C1",
                          [NSNumber numberWithFloat:34.65]:@"C#1/Db1",
                          [NSNumber numberWithFloat:36.71]:@"D1",
                          [NSNumber numberWithFloat:38.89]:@"D#1/Eb1",
                          [NSNumber numberWithFloat:41.2]:@"E1",
                          [NSNumber numberWithFloat:43.65]:@"F1",
                          [NSNumber numberWithFloat:46.25]:@"F#1/Gb1",
                          [NSNumber numberWithFloat:49.0]:@"G1",
                          [NSNumber numberWithFloat:51.91]:@"G#1/Ab1",
                          [NSNumber numberWithFloat:55.0]:@"A1",
                          [NSNumber numberWithFloat:58.27]:@"A#1/Bb1",
                          [NSNumber numberWithFloat:61.74]:@"B1",
                          [NSNumber numberWithFloat:65.41]:@"C2",
                          [NSNumber numberWithFloat:69.3]:@"C#2/Db2",
                          [NSNumber numberWithFloat:73.42]:@"D2",
                          [NSNumber numberWithFloat:77.78]:@"D#2/Eb2",
                          [NSNumber numberWithFloat:82.41]:@"E2",
                          [NSNumber numberWithFloat:87.31]:@"F2",
                          [NSNumber numberWithFloat:92.5]:@"F#2/Gb2",
                          [NSNumber numberWithFloat:98.0]:@"G2",
                          [NSNumber numberWithFloat:103.83]:@"G#2/Ab2",
                          [NSNumber numberWithFloat:110.0]:@"A2",
                          [NSNumber numberWithFloat:116.54]:@"A#2/Bb2",
                          [NSNumber numberWithFloat:123.47]:@"B2",
                          [NSNumber numberWithFloat:130.81]:@"C3",
                          [NSNumber numberWithFloat:138.59]:@"C#3/Db3",
                          [NSNumber numberWithFloat:146.83]:@"D3",
                          [NSNumber numberWithFloat:155.56]:@"D#3/Eb3",
                          [NSNumber numberWithFloat:164.81]:@"E3",
                          [NSNumber numberWithFloat:174.61]:@"F3",
                          [NSNumber numberWithFloat:185.0]:@"F#3/Gb3",
                          [NSNumber numberWithFloat:196.0]:@"G3",
                          [NSNumber numberWithFloat:207.65]:@"G#3/Ab3",
                          [NSNumber numberWithFloat:220.0]:@"A3",
                          [NSNumber numberWithFloat:233.08]:@"A#3/Bb3",
                          [NSNumber numberWithFloat:246.94]:@"B3",
                          [NSNumber numberWithFloat:261.63]:@"C4",
                          [NSNumber numberWithFloat:277.18]:@"C#4/Db4",
                          [NSNumber numberWithFloat:293.66]:@"D4",
                          [NSNumber numberWithFloat:311.13]:@"D#4/Eb4",
                          [NSNumber numberWithFloat:329.63]:@"E4",
                          [NSNumber numberWithFloat:349.23]:@"F4",
                          [NSNumber numberWithFloat:369.99]:@"F#4/Gb4",
                          [NSNumber numberWithFloat:392.0]:@"G4",
                          [NSNumber numberWithFloat:415.3]:@"G#4/Ab4",
                          [NSNumber numberWithFloat:440.0]:@"A4",
                          [NSNumber numberWithFloat:466.16]:@"A#4/Bb4",
                          [NSNumber numberWithFloat:493.88]:@"B4",
                          [NSNumber numberWithFloat:523.25]:@"C5",
                          [NSNumber numberWithFloat:554.37]:@"C#5/Db5",
                          [NSNumber numberWithFloat:587.33]:@"D5",
                          [NSNumber numberWithFloat:622.25]:@"D#5/Eb5",
                          [NSNumber numberWithFloat:659.25]:@"E5",
                          [NSNumber numberWithFloat:698.46]:@"F5",
                          [NSNumber numberWithFloat:739.99]:@"F#5/Gb5",
                          [NSNumber numberWithFloat:783.99]:@"G5",
                          [NSNumber numberWithFloat:830.61]:@"G#5/Ab5",
                          [NSNumber numberWithFloat:880.0]:@"A5",
                          [NSNumber numberWithFloat:932.33]:@"A#5/Bb5",
                          [NSNumber numberWithFloat:987.77]:@"B5",
                          [NSNumber numberWithFloat:1046.5]:@"C6",
                          [NSNumber numberWithFloat:1108.73]:@"C#6/Db6",
                          [NSNumber numberWithFloat:1174.66]:@"D6",
                          [NSNumber numberWithFloat:1244.51]:@"D#6/Eb6",
                          [NSNumber numberWithFloat:1318.51]:@"E6",
                          [NSNumber numberWithFloat:1396.91]:@"F6",
                          [NSNumber numberWithFloat:1479.98]:@"F#6/Gb6",
                          [NSNumber numberWithFloat:1567.98]:@"G6",
                          [NSNumber numberWithFloat:1661.22]:@"G#6/Ab6",
                          [NSNumber numberWithFloat:1760.0]:@"A6",
                          [NSNumber numberWithFloat:1864.66]:@"A#6/Bb6",
                          [NSNumber numberWithFloat:1975.53]:@"B6",
                          [NSNumber numberWithFloat:2093.0]:@"C7",
                          [NSNumber numberWithFloat:2217.46]:@"C#7/Db7",
                          [NSNumber numberWithFloat:2349.32]:@"D7",
                          [NSNumber numberWithFloat:2489.02]:@"D#7/Eb7",
                          [NSNumber numberWithFloat:2637.02]:@"E7",
                          [NSNumber numberWithFloat:2793.83]:@"F7",
                          [NSNumber numberWithFloat:2959.96]:@"F#7/Gb7",
                          [NSNumber numberWithFloat:3135.96]:@"G7",
                          [NSNumber numberWithFloat:3322.44]:@"G#7/Ab7",
                          [NSNumber numberWithFloat:3520.0]:@"A7",
                          [NSNumber numberWithFloat:3729.31]:@"A#7/Bb7",
                          [NSNumber numberWithFloat:3951.07]:@"B7",
                          [NSNumber numberWithFloat:4186.01]:@"C8",
                          [NSNumber numberWithFloat:4434.92]:@"C#8/Db8",
                          [NSNumber numberWithFloat:4698.63]:@"D8",
                          [NSNumber numberWithFloat:4978.03]:@"D#8/Eb8",
                          [NSNumber numberWithFloat:5274.04]:@"E8",
                          [NSNumber numberWithFloat:5587.65]:@"F8",
                          [NSNumber numberWithFloat:5919.91]:@"F#8/Gb8",
                          [NSNumber numberWithFloat:6271.93]:@"G8",
                          [NSNumber numberWithFloat:6644.88]:@"G#8/Ab8",
                          [NSNumber numberWithFloat:7040.0]:@"A8",
                          [NSNumber numberWithFloat:7458.62]:@"A#8/Bb8",
                          [NSNumber numberWithFloat:7902.13]:@"B8"
                          };
    }
    return _planoNoteMap;
}

-(void)start{
    __block AudioAnalyzer * __weak weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    [self.audioManager setOutputBlock:nil];

    if (![self.audioManager playing]) {
        [self.audioManager play];
    }
}

-(void)start:(float)frequency{
    __block AudioAnalyzer * __weak weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    [self updateFrequencyInKhz:frequency];
    __block float phase = 0.0;
    [self.audioManager setOutputBlock:^(float* data, UInt32 numFrames, UInt32 numChannels){
        for (int n=0; n<numFrames; n++) {
            data[n] = sin(phase);
            phase += self.phaseIncrement;
        }
    }];

    if (![self.audioManager playing]) {
        [self.audioManager play];
    }
}

-(void)stop{
    [self.audioManager pause];
}

-(void)fetchData:(float *)data
      withLength:(SInt64)length
         withFft:(float *)fft {
    [self.buffer fetchFreshData:data withNumSamples:length];
    [self.fftHelper performForwardFFTWithData:data
                   andCopydBMagnitudeToBuffer:fft];
}

-(void)fetchData:(float *)data
      withLength:(SInt64)length
         withFft:(float *)fft
          inZoom:(int)zoom
        withZoom:(float *)fftZoom{
    [self.buffer fetchFreshData:data withNumSamples:length];
    [self.fftHelper performForwardFFTWithData:data
                   andCopydBMagnitudeToBuffer:fft];
    
    for (int i = 0, j = (int)length/2/zoom*2; j < length/2 - 2; ++i, ++j) {
        fftZoom[i] = fft[j];
    }
}

- (float)guessPlanoFreq:(NSArray*)peakArray {
    float guessFreq = 0.0;
    
    if (peakArray || (1 < peakArray.count)) {
        float firstMinFreq = FLT_MAX;
        float secondMinFreq = FLT_MAX;
        
        for (int i=0; i<peakArray.count; i++) {
            Peak *peak = (Peak*)peakArray[i];
            if (firstMinFreq > peak.frequency) {
                firstMinFreq = peak.frequency;
            }
        }
        
        for (int i=0; i<peakArray.count; i++) {
            Peak *peak = (Peak*)peakArray[i];
            if ((firstMinFreq != peak.frequency) && (secondMinFreq > peak.frequency)) {
                secondMinFreq = peak.frequency;
            }
        }
        
        float guessRate = secondMinFreq/firstMinFreq; // 2:1 case
        float halfFreq = firstMinFreq/2;
        float guessRateN = secondMinFreq/halfFreq; // N:2 case
        if(PLANO_DIV_ERR > (guessRate - floorf(guessRate))){
            guessFreq = firstMinFreq;
        } else if (PLANO_DIV_ERR > (guessRateN - floorf(guessRateN))) {
            guessFreq = halfFreq;
        } else {
            guessFreq = firstMinFreq;
        }
    }
    
    return guessFreq;
}

- (void)analyzePlanoNote:(NSArray*)peakArray forAudioInfo:(AudioInfo*)audioInfo {
    if (!_date) {
        _date = [NSDate date];
    }
    
    BOOL isChangeFreq = false;
    if(peakArray){
        float guessFreq = [self guessPlanoFreq:peakArray];

        if (guessFreq) {
            NSDate *refDate = [NSDate date];
            double elapsed = [refDate timeIntervalSinceDate:_date];
            
            if ((1 < elapsed) || (!audioInfo.planoFreq)) {
                isChangeFreq = true;
                audioInfo.planoFreq = guessFreq;
            } else if (audioInfo.planoFreq < guessFreq) {
                float rate = guessFreq/audioInfo.planoFreq;
                if(PLANO_DIV_ERR < (rate - floorf(rate))){
                    isChangeFreq = true;
                    audioInfo.planoFreq = guessFreq;
                }
            } else {
                isChangeFreq = true;
                audioInfo.planoFreq = guessFreq;
            }
        }
    }

    if (isChangeFreq) {
        _date = [NSDate date];
        NSString *note = @"";
        float closestDiff = FLT_MAX;
        float planoNoteFreq = 0.0;

        for (id key in self.planoNoteMap) {
            float diff = fabsf(audioInfo.planoFreq - [key floatValue]);
            if (closestDiff > diff) {
                planoNoteFreq = [key floatValue];
                closestDiff = diff;
                note = [self.planoNoteMap objectForKey:key];
            }
        }
        
        if (closestDiff <= PLANO_NOTE_TOL) {
            audioInfo.planoNoteText = note;
            audioInfo.planoNoteFreq = planoNoteFreq;
        }
    }
}

-(void)analyzeAudio:(float*) fft
       forAudioInfo:(AudioInfo *)audioInfo{
    NSArray *peakArray = [self.peakFinder getFundamentalPeaksFromBuffer:fft
                                                             withLength:_bufferSize/2
                                                        usingWindowSize:WINDOWS_SIZE
                                                andPeakMagnitudeMinimum:MIN_MAGNITUDE
                                                         aboveFrequency:MIN_FREQUENCY];
    if(peakArray){
        Peak *firstPeak = (Peak*)peakArray[0];
        audioInfo.firstFreq = firstPeak.frequency;
        audioInfo.firstDecibel = firstPeak.magnitude;
        if (1<peakArray.count){
            Peak *secondPeak = (Peak*)peakArray[1];
            audioInfo.secondFreq = secondPeak.frequency;
            audioInfo.secondDecibel = secondPeak.magnitude;
        }

        for (int i=0; i<peakArray.count; i++) {
            Peak *peak = (Peak*)peakArray[i];
            NSLog(@"idx=[%d] Freq=%f Hz (%f dB)", i, peak.frequency, peak.magnitude);
            fflush(stderr);
        }
    }

    [self analyzePlanoNote:peakArray forAudioInfo:audioInfo];
    
    static NSString *note = @"";
    if (note != audioInfo.planoNoteText) {
        note = audioInfo.planoNoteText;
        NSLog(@"note=[%@] freq=%f Hz", audioInfo.planoNoteText, audioInfo.planoNoteFreq);
    }
}

-(void)updateFrequencyInKhz:(float) freqInKHz {
    self.frequency = freqInKHz*1000.0;
    self.phaseIncrement = 2*M_PI*self.frequency/self.audioManager.samplingRate;
    
}

-(NSMutableString*)analyzeDoppler:(float*)fft
              withLen:(SInt64)length{
    NSMutableString* answer = [[NSMutableString alloc] init];
    
    float delta = self.audioManager.samplingRate/length;
    int freqIndex = (self.frequency/delta)*2;
    int freqWindow = 500/delta;
    int dopplerWindow = 300/delta;
    
    
    float maxValue;
    unsigned long maxIndex;
    vDSP_maxvi(&(fft[freqIndex - freqWindow]), 1, &maxValue, &maxIndex, freqWindow * 2);
    NSLog(@"DB=%f Idx=%lu Rl=%d", maxValue, maxIndex + (freqIndex - freqWindow), freqIndex);
    
    float maxValueLeft;
    vDSP_maxv(&fft[maxIndex - dopplerWindow], 1, &maxValueLeft, dopplerWindow - 5);
    NSLog(@"MAX=%f", maxValueLeft);
    if(maxValue * .6 < maxValueLeft) {
        [answer appendString:@"Moving away\n"];
    }

    float maxValueRight;
    vDSP_maxv(&fft[maxIndex + 5], 1, &maxValueRight, dopplerWindow);
    NSLog(@"MAX=%f", maxValueRight);
    if(maxValue * .6 < maxValueRight) {
        [answer appendString:@"Moving towards\n"];
    }
    
    return answer;
}

@end
