//
//  CurrencyViewController.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/31/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "CurrencyViewController.h"
#import "AppModel.h"

@interface CurrencyViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISwitch *conversionSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *conversionResult;
@property (weak, nonatomic) IBOutlet UILabel *conversionInput;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property(nonatomic, assign) NSInteger index;
@property (strong, nonatomic) AppModel *appModel;
@property (strong, nonatomic) NSString* currencyTargetName;
@property (strong, nonatomic) NSString* currencyInputName;
@property (strong, nonatomic) NSNumber* currencyTargetNumber;
@property (strong, nonatomic) NSNumber* currencyInputNumber;
@property (strong, nonatomic) NSNumber* dolarPrice;
@property (strong, nonatomic) NSNumber* numberOfZeros;
@end

@implementation CurrencyViewController

-(AppModel*)appModel {
    if (!_appModel) {
        _appModel = [AppModel sharedInstance];
    }
    return _appModel;
}

-(NSString*)currencyTargetName{
    if (!_currencyTargetName) {
        _currencyTargetName = [self.appModel getCountryData: self.index][@"currencyShortName"];
    }
    return _currencyTargetName;
}

-(NSString*)currencyInputName{
    if (!_currencyInputName) {
        _currencyInputName = @"USD";
    }
    return _currencyInputName;
}

-(NSNumber*)currencyTargetNumber{
    if (!_currencyTargetNumber) {
        _currencyTargetNumber = @(self.slider.value * 1 / [self.dolarPrice floatValue]);
    }
    return _currencyTargetNumber;
}

-(NSNumber*)currencyInputNumber{
    if (!_currencyInputNumber) {
        _currencyInputNumber = @(self.slider.value);
    }
    return _currencyInputNumber;
}

-(NSNumber*)dolarPrice{
    if (!_dolarPrice) {
        _dolarPrice = [self.appModel getCountryData: self.index][@"dollarPrice"];
    }
    return _dolarPrice;
}

-(NSNumber*)numberOfZeros{
    if (!_numberOfZeros) {
        _numberOfZeros = @1;
    }
    return _numberOfZeros;
}

- (IBAction)onSliderChange:(id)sender {
    [self updateValueLabels];
}

- (IBAction)onSwitchChange:(id)sender {
    NSString* temp = self.currencyTargetName;
    self.currencyTargetName = self.currencyInputName;
    self.currencyInputName = temp;
    [self updateValueLabels];
}

- (IBAction)onStepperChange:(id)sender {
    if(_stepper.value > [_numberOfZeros doubleValue]) {
        _slider.maximumValue = _slider.maximumValue * 10;
        _slider.minimumValue = _slider.minimumValue * 10;
        _slider.value = _slider.value * 10;
    } else {
        _slider.value = _slider.value / 10;
        _slider.maximumValue = _slider.maximumValue / 10;
        _slider.minimumValue = _slider.minimumValue / 10;
    }
    _numberOfZeros = @(_stepper.value);
    [self updateValueLabels];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countryPicker.dataSource = self;
    self.countryPicker.delegate = self;

    self.index = 0;
    [self updateTitleLabel];
    [self updateValueLabels];
}

-(void)updateTitleLabel {
    NSDictionary* data = [self.appModel getCountryData: self.index];
    self.titleLabel.text = [NSString stringWithFormat:@"%@'s currency: %@", data[@"name"], data[@"currencyName"]];
    self.dolarPrice = data[@"dollarPrice"];
    if (_conversionSwitch.isOn) {
        self.currencyTargetName = data[@"currencyShortName"];
    } else {
        self.currencyInputName = data[@"currencyShortName"];
    }
}

-(void)updateValueLabels {
    self.currencyInputNumber = @(_slider.value);

    if (self.conversionSwitch.isOn) {
        self.currencyTargetNumber = @(_slider.value / [self.dolarPrice floatValue]);
    } else {
        self.currencyTargetNumber = @(_slider.value * [self.dolarPrice floatValue]);
    }

    self.conversionResult.text = [NSString stringWithFormat:@"$%.2f %@", [self.currencyTargetNumber floatValue], self.currencyTargetName];
    self.conversionInput.text = [NSString stringWithFormat:@"$%.2f %@", [self.currencyInputNumber floatValue], self.currencyInputName];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.appModel getCountryCount];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.appModel getCountryData: row][@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.index = row;
    [self updateTitleLabel];
    [self updateValueLabels];
}

@end
