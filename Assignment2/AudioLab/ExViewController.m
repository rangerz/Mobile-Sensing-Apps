//
//  ExViewController.m
//  AudioLab
//
//  Created by Ranger on 9/21/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#define BUFFER_SIZE 2048*8
#define FFT_ZOOM 3
#define FREQ_KHZ 20

#import "ExViewController.h"
#import "UIImage+animatedGIF.h"
#import "AudioAnalyzer.h"
#import "SMUGraphHelper.h"

@interface ExViewController ()
@property (strong, nonatomic) AudioAnalyzer *audioAnalyzer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ExViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Dribble" withExtension:@"gif"];
    UIImage *image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    self.imageView.animationImages = image.images;
    self.imageView.animationDuration = image.duration;
    self.imageView.animationRepeatCount = 3; // for demo
    self.imageView.image = image.images.lastObject;
    [self.imageView startAnimating];

    [self.audioAnalyzer start:FREQ_KHZ];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.audioAnalyzer stop];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.audioAnalyzer start:FREQ_KHZ];
}

- (void)update{
    // just plot the audio stream
    
    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    float* fftMagnitudeZoom = malloc(sizeof(float)*BUFFER_SIZE/2/FFT_ZOOM);

    // get audio data and FFT
    [self.audioAnalyzer fetchData:arrayData withLength:BUFFER_SIZE withFft:fftMagnitude inZoom:FFT_ZOOM withZoom:fftMagnitudeZoom];

    DopplerState status = [self.audioAnalyzer analyzeDoppler:fftMagnitude withLen:BUFFER_SIZE/2];
    [self updateBallSatus:status];

    free(arrayData);
    free(fftMagnitude);
    free(fftMagnitudeZoom);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

- (void)updateBallSatus:(DopplerState)status {
    static BOOL towards = false;
    
    if (false == towards) {
        if (status & DS_Towards) {
            if (![self.imageView isAnimating]) {
                self.imageView.animationRepeatCount = 1;
                [self.imageView startAnimating];
                towards = true;
            }
        }
    } else {
        if (status & DS_Away) {
            towards = false;
        }
    }
}
@end
