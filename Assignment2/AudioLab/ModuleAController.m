//
//  ModuleAController.m
//  AudioLab
//
//  Created by Ranger on 9/18/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "ModuleAController.h"
#import "AudioAnalyzer.h"
#import "SMUGraphHelper.h"

#define BUFFER_SIZE 2048*32

@interface ModuleAController ()
@property (strong, nonatomic) AudioAnalyzer *audioAnalyzer;
@property (nonatomic, strong) AudioInfo *audioInfo;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *firstFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *planoNoteLabel;
@end

@implementation ModuleAController

#pragma mark Lazy Instantiation

-(AudioAnalyzer*)audioAnalyzer{
    if(!_audioAnalyzer){
        _audioAnalyzer = [[AudioAnalyzer alloc] initWithSize:BUFFER_SIZE];
    }
    return _audioAnalyzer;
}

-(AudioInfo*)audioInfo{
    if(!_audioInfo){
        _audioInfo = [[AudioInfo alloc] init];
    }
    return _audioInfo;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.graphHelper setBoundsWithTop:0.2 bottom:-1.0 left:-0.95 right:0.95];
    [self.audioAnalyzer start];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.audioAnalyzer stop];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.audioAnalyzer start];
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
    
    // get audio data and FFT
    [self.audioAnalyzer fetchData:arrayData withLength:BUFFER_SIZE withFft:fftMagnitude];

    //send off for graphing
    [self.graphHelper setGraphData:arrayData
                    withDataLength:BUFFER_SIZE
                     forGraphIndex:0];
    
    // graph the FFT Data
    [self.graphHelper setGraphData:fftMagnitude
                    withDataLength:BUFFER_SIZE/2
                     forGraphIndex:1
                 withNormalization:64.0
                     withZeroValue:-60];

    [self.audioAnalyzer analyzeAudio:fftMagnitude
                        forAudioInfo:_audioInfo];
    [self updateLabel];
    [self.graphHelper update]; // update the graph
    free(arrayData);
    free(fftMagnitude);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

- (void)updateLabel{
    if((0 != self.audioInfo.firstFreq) || (0 != self.audioInfo.firstDecibel)){
        self.firstFreqLabel.text = [NSString stringWithFormat: @"1st Frequency: %.1f Hz (%.1f dB)", self.audioInfo.firstFreq, self.audioInfo.firstDecibel];
    } else {
        self.firstFreqLabel.text = @"1st Frequency: Detecting...";
    }

    if((0 != self.audioInfo.secondFreq) || (0 != self.audioInfo.secondDecibel)){
        self.secondFreqLabel.text = [NSString stringWithFormat: @"2nd Frequency: %.1f Hz (%.1f dB)", self.audioInfo.secondFreq, self.audioInfo.secondDecibel];
    } else {
        self.secondFreqLabel.text = @"2nd Frequency: Detecting...";
    }

    if((0 != self.audioInfo.planoFreq) || (0 != self.audioInfo.planoNoteFreq)){
        self.planoNoteLabel.text = [NSString stringWithFormat: @"Plano Note: %@ (%0.2f Hz)", self.audioInfo.planoNoteText, self.audioInfo.planoNoteFreq];
    } else {
        self.planoNoteLabel.text = [NSString stringWithFormat: @"Plano Note: Detecting..."];
    }
}

@end
