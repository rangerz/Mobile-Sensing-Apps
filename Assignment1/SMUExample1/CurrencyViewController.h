//
//  CurrencyViewController.h
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/31/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISwitch *conversionSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *conversionResult;
@property (weak, nonatomic) IBOutlet UILabel *conversionInput;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) NSArray* countries;

@end

NS_ASSUME_NONNULL_END
