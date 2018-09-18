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

#define BUFFER_SIZE 2048*4

@interface ModuleAController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (weak, nonatomic) IBOutlet UILabel *firstFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *planoNoteLabel;
@property (nonatomic) float firstFreq;
@property (nonatomic) float secondFreq;
@property (nonatomic) float firstDecibel;
@property (nonatomic) float secondDecibel;
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
                                                       numGraphs:1
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    // just plot the audio stream
    
    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    //send off for graphing
//    [self.graphHelper setGraphData:arrayData
//                    withDataLength:BUFFER_SIZE
//                     forGraphIndex:0];
    
    // take forward FFT
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    // graph the FFT Data
    [self.graphHelper setGraphData:fftMagnitude
                    withDataLength:BUFFER_SIZE/2
                     forGraphIndex:0
                 withNormalization:64.0
                     withZeroValue:-60];
    [self updateLabel];
    [self.graphHelper update]; // update the graph
    free(arrayData);
    free(fftMagnitude);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

- (void)updateLabel {
    ///TODO: get correct value
    self.firstFreq++;
    self.secondFreq++;
    NSString *note = @"A4";
    self.firstFreqLabel.text = [NSString stringWithFormat: @"1st Frequency: %.1f Hz (%.1f dB)", self.firstFreq, self.firstDecibel];
    self.secondFreqLabel.text = [NSString stringWithFormat: @"2nd Frequency: %.1f Hz (%.1f dB)", self.secondFreq, self.secondDecibel];
    self.planoNoteLabel.text = [NSString stringWithFormat: @"Plano Note: %@ (X Hz)", note];
}

@end
