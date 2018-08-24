//
//  ViewController.m
//  Example2018
//
//  Created by Eric Larson on 8/21/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ericLabel;
@property (strong, nonatomic) NSNumber* number;
@end

@implementation ViewController
@synthesize number = _number;

-(NSNumber*)number{
    if(!_number){
        _number = @1;
    }
    return _number;
}

-(void)setNumber:(NSNumber *)number{
    _number = number;
    self.ericLabel.text = [NSString stringWithFormat:@"%.2f",[self.number floatValue]];
    //self.number
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didPressButton:(UIButton *)sender {
    [self changeLabel:self.ericLabel withString:@"Eric"];
}

- (void)changeLabel:(UILabel* )label
         withString:(NSString*)string
{
    label.text = string;
}
- (IBAction)sliderChanged:(UISlider *)sender {
    self.number = @(sender.value);
}


@end














