//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "SMUGraphHelper.h"
#import "FFTHelper.h"
#import "AudioFileReader.h"

#define BUFFER_SIZE 2048*4
#define EQUALIZER_SIZE 20

@interface ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) AudioFileReader *fileReader;
@end

@implementation ViewController

-(AudioFileReader*)fileReader{
    if (!_fileReader) {
        NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"satisfaction" withExtension:@"mp3"];
        _fileReader = [[AudioFileReader alloc]
                       initWithAudioFileURL:inputFileURL
                       samplingRate:self.audioManager.samplingRate
                       numChannels:self.audioManager.numOutputChannels];
    }
    return _fileReader;
}

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
                                        preferredFramesPerSecond:15
                                                       numGraphs:3
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


#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        __block ViewController * __weak weakSelf = self;
    
    [self.fileReader play];
    self.fileReader.currentTime = 0.0;

    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        [weakSelf.fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    [self.graphHelper setFullScreenBounds];
    //self.edgesForExtendedLayout =  NO;
    
//    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
//        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
//    }];
    
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

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    // just plot the audio stream
    
    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    float* equalizerData = malloc(sizeof(float)*EQUALIZER_SIZE);
    
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

    float maxVal = 0.0;
    int unit = BUFFER_SIZE/EQUALIZER_SIZE/2;
    for (int i=0; i<EQUALIZER_SIZE; i++) {
        vDSP_maxv(&fftMagnitude[i*unit], 1, &maxVal, unit);
        equalizerData[i] = maxVal;
    }
    
#if 0 // direct implement
    for (int i=0; i<EQUALIZER_SIZE; i++) {
        float max = -FLT_MAX;
        for (int j=0; j<unit; j++) {
            if (max < fftMagnitude[i*unit + j]) {
                max = fftMagnitude[i*unit + j];
            }
        }
        equalizerData[i] = max;
    }
#endif

    // graph the equalizer
    [self.graphHelper setGraphData:equalizerData
                    withDataLength:EQUALIZER_SIZE
                     forGraphIndex:2
                 withNormalization:64.0
                     withZeroValue:-60];
    
    [self.graphHelper update]; // update the graph
    free(arrayData);
    free(fftMagnitude);
    free(equalizerData);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}


@end
