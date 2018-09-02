//
//  CurrencyViewController.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/31/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "CurrencyViewController.h"

@interface CurrencyViewController ()

@property (strong, nonatomic) NSMutableArray* countryList;
@property (strong, nonatomic) NSString* currencyTargetName;
@property (strong, nonatomic) NSString* currencyInputName;
@property (strong, nonatomic) NSNumber* currencyTargetNumber;
@property (strong, nonatomic) NSNumber* currencyInputNumber;
@property (strong, nonatomic) NSNumber* dolarPrice;
@property (strong, nonatomic) NSNumber* numberOfZeros;

@end

@implementation CurrencyViewController

-(NSString*)currencyTargetName{
    if(!_currencyTargetName)
        _currencyTargetName = self.countries[0][@"currencyShortName"];
    return _currencyTargetName;
}

-(NSString*)currencyInputName{
    if(!_currencyInputName)
        _currencyInputName = @"USD";
    return _currencyInputName;
}

-(NSNumber*)currencyTargetNumber{
    if(!_currencyTargetNumber)
        _currencyTargetNumber = @(self.slider.value * 1 / [self.dolarPrice floatValue]);
    return _currencyTargetNumber;
}

-(NSNumber*)currencyInputNumber{
    if(!_currencyInputNumber)
        _currencyInputNumber = @(self.slider.value);
    return _currencyInputNumber;
}

-(NSNumber*)dolarPrice{
    if(!_dolarPrice)
        _dolarPrice = self.countries[0][@"dollarPrice"];
    return _dolarPrice;
}

-(NSNumber*)numberOfZeros{
    if(!_numberOfZeros)
        _numberOfZeros = @1;
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

-(NSMutableArray*)countryList{
    if (!_countryList) {
        _countryList = [[NSMutableArray alloc] init];
        for (NSDictionary* country in self.countries) {
            [_countryList addObject:country[@"name"]];
        }
    }
    return _countryList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.countryPicker.dataSource = self;
    self.countryPicker.delegate = self;
    
    [self updateTitleLabel:0];
    [self updateValueLabels];
}

-(void)updateTitleLabel:(NSInteger)index {
    self.titleLabel.text = self.countries[0][@"name"];
    self.titleLabel.text = [NSString stringWithFormat:@"%@'s currency: %@", self.countries[index][@"name"], self.countries[index][@"currencyName"]];
    self.dolarPrice = self.countries[index][@"dollarPrice"];
    if(_conversionSwitch.isOn) {
        self.currencyTargetName = self.countries[index][@"currencyShortName"];
    } else {
        self.currencyInputName = self.countries[index][@"currencyShortName"];
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.countryList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.countryList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self updateTitleLabel:row];
    [self updateValueLabels];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
