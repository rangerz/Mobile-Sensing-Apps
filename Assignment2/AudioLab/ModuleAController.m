//
//  ModuleAController.m
//  AudioLab
//
//  Created by Ranger on 9/18/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "ModuleAController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "SMUGraphHelper.h"
#import "FFTHelper.h"
#import "PeakFinder.h"

#define BUFFER_SIZE 2048*4
#define WINDOWS_SIZE 20
#define MIN_MAGNITUDE 5
#define MIN_FREQUENCY 50
#define PLANO_NOTE_TOL 10.0

@interface ModuleAController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) PeakFinder *peakFinder;
@property (strong, nonatomic) NSDictionary *planoNoteMap;
@property (weak, nonatomic) IBOutlet UILabel *firstFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *planoNoteLabel;
@property (nonatomic) float firstFreq;
@property (nonatomic) float secondFreq;
@property (nonatomic) float firstDecibel;
@property (nonatomic) float secondDecibel;
@property (nonatomic) float planoFreq;
@end

@implementation ModuleAController

#pragma mark Lazy Instantiation
-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}

-(SMUGraphHelper*)graphHelper{
    if(!_graphHelper){
        _graphHelper = [[SMUGraphHelper alloc]initWithController:self
                                        preferredFramesPerSecond:30
                                                       numGraphs:2
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:BUFFER_SIZE];
    }
    return _graphHelper;
}

-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    
    return _fftHelper;
}

-(PeakFinder*)peakFinder{
    if(!_peakFinder){
        _peakFinder = [[PeakFinder alloc]initWithFrequencyResolution:(((float)self.audioManager.samplingRate) / ((float)(BUFFER_SIZE)))];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.graphHelper setBoundsWithTop:0.5 bottom:-1.0 left:-0.9 right:0.9];

    __block ModuleAController * __weak weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];

    [self.audioManager play];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.audioManager pause];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.audioManager playing]) {
        [self.audioManager play];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    // just plot the audio stream

    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    //send off for graphing
    [self.graphHelper setGraphData:arrayData
                    withDataLength:BUFFER_SIZE
                     forGraphIndex:0];
    
    // take forward FFT
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    // graph the FFT Data
    [self.graphHelper setGraphData:fftMagnitude
                    withDataLength:BUFFER_SIZE/2
                     forGraphIndex:1
                 withNormalization:64.0
                     withZeroValue:-60];

    NSArray *peakArray = [self.peakFinder getFundamentalPeaksFromBuffer:fftMagnitude
                                                             withLength:BUFFER_SIZE/2
                                                        usingWindowSize:WINDOWS_SIZE
                                                andPeakMagnitudeMinimum:MIN_MAGNITUDE
                                                         aboveFrequency:MIN_FREQUENCY];
    if(peakArray){
        Peak *firstPeak = (Peak*)peakArray[0];
        self.firstFreq = firstPeak.frequency;
        self.firstDecibel = firstPeak.magnitude;
        if (1<peakArray.count){
            Peak *secondPeak = (Peak*)peakArray[1];
            self.secondFreq = secondPeak.frequency;
            self.secondDecibel = secondPeak.magnitude;
        }

        for (int i=0; i<peakArray.count; i++) {
            Peak *peak = (Peak*)peakArray[i];
            NSLog(@"idx=[%d] Freq=%f Hz (%f dB)", i, peak.frequency, peak.magnitude);
        }
        
        self.planoFreq = self.firstFreq;

        // self.planoFreq = 0;
    }

    [self updateLabel];
    [self.graphHelper update]; // update the graph
    free(arrayData);
    free(fftMagnitude);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

- (NSString*)getPlanoNote {
    NSString* noteText = @"";
    float closestDiff = FLT_MAX;
    float planoFreq = 0.0;
    NSString *note = @"";

    for (id key in self.planoNoteMap) {
        float diff = fabsf(self.planoFreq - [key floatValue]);
        if (closestDiff > diff) {
            planoFreq = [key floatValue];
            closestDiff = diff;
            note = [self.planoNoteMap objectForKey:key];
        }
    }

    if (closestDiff <= PLANO_NOTE_TOL) {
        noteText = [NSString stringWithFormat: @"%@ (%0.2f Hz)", note, planoFreq];
    } else {
        noteText = @"...";
    }
    
    return noteText;
}

- (void)updateLabel{
    if((0 != self.firstFreq) || (0 != self.firstDecibel)){
        self.firstFreqLabel.text = [NSString stringWithFormat: @"1st Frequency: %.1f Hz (%.1f dB)", self.firstFreq, self.firstDecibel];
    } else {
        self.firstFreqLabel.text = @"1st Frequency: Detecting...";
    }

    if((0 != self.secondFreq) || (0 != self.secondDecibel)){
        self.secondFreqLabel.text = [NSString stringWithFormat: @"2nd Frequency: %.1f Hz (%.1f dB)", self.secondFreq, self.secondDecibel];
    } else {
        self.secondFreqLabel.text = @"2nd Frequency: Detecting...";
    }
    
    NSString *note = [self getPlanoNote];
    self.planoNoteLabel.text = [NSString stringWithFormat: @"Plano Note: %@", note];
}

@end
