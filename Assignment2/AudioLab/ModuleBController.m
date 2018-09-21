//
//  ModuleBController.m
//  AudioLab
//
//  Created by Ranger on 9/18/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#define BUFFER_SIZE 2048*8
#define FFT_ZOOM 3

#import "ModuleBController.h"
#import "AudioAnalyzer.h"
#import "SMUGraphHelper.h"

@interface ModuleBController ()
@property (strong, nonatomic) AudioAnalyzer *audioAnalyzer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UISlider *freqSlider;
@property (weak, nonatomic) IBOutlet UILabel *freqLabel;
@end

@implementation ModuleBController

#pragma mark Lazy Instantiation

-(AudioAnalyzer*)audioAnalyzer{
    if(!_audioAnalyzer){
        _audioAnalyzer = [[AudioAnalyzer alloc] initWithSize:BUFFER_SIZE];
    }
    return _audioAnalyzer;
}

-(SMUGraphHelper*)graphHelper{
    if(!_graphHelper){
        _graphHelper = [[SMUGraphHelper alloc]initWithController:self
                                        preferredFramesPerSecond:30
                                                       numGraphs:1
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:BUFFER_SIZE];
    }
    return _graphHelper;
}

- (IBAction)freqChanged:(UISlider *)sender {
    [self updateFreqLabel:sender.value];
    [self.audioAnalyzer updateFrequencyInKhz:sender.value];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.graphHelper setBoundsWithTop:0.2 bottom:-1.0 left:-0.95 right:0.95];
    [self.audioAnalyzer start:self.freqSlider.value];
    [self updateFreqLabel:self.freqSlider.value];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.audioAnalyzer stop];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.audioAnalyzer start:self.freqSlider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateFreqLabel:(float)freq {
    self.freqLabel.text = [NSString stringWithFormat:@"%.4f kHz",freq*1000.0];
}

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    // just plot the audio stream

    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    float* fftMagnitudeZoom = malloc(sizeof(float)*BUFFER_SIZE/2/FFT_ZOOM);

    // get audio data and FFT
    [self.audioAnalyzer fetchData:arrayData withLength:BUFFER_SIZE withFft:fftMagnitude inZoom:FFT_ZOOM withZoom:fftMagnitudeZoom];

    // graph the FFT Data with Zoom
    [self.graphHelper setGraphData:fftMagnitudeZoom
                    withDataLength:BUFFER_SIZE/2/FFT_ZOOM
                     forGraphIndex:0
                 withNormalization:64.0 * 2
                     withZeroValue:-60];
    
    DopplerState status = [self.audioAnalyzer analyzeDoppler:fftMagnitude withLen:BUFFER_SIZE/2];
    [self updateLabel:status];

    [self.graphHelper update]; // update the graph
    free(arrayData);
    free(fftMagnitude);
    free(fftMagnitudeZoom);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

- (void)updateLabel:(DopplerState)status {
    NSString* answer = @"";
    if ((status & DS_Towards) && (status & DS_Away)) {
        answer = @"Towards and Away";
    } else if (status & DS_Towards) {
        answer = @"Towards";
    } else if (status & DS_Away) {
        answer = @"Away";
    } else {
        answer = @"Still";
    }
    self.answerLabel.text = answer;
}

@end
