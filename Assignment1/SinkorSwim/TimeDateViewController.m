//
//  TimeDateViewController.m
//  SMUExample1
//
//  Created by RR on 9/3/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "TimeDateViewController.h"
#import "AppModel.h"

@interface TimeDateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property(nonatomic, assign) NSInteger index;
@property (strong, nonatomic) AppModel *appModel;
@property(nonatomic, strong) NSTimer *timer;
@end

@implementation TimeDateViewController

-(AppModel*)appModel {
    if (!_appModel) {
        _appModel = [AppModel sharedInstance];
    }
    return _appModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countryPicker.dataSource = self;
    self.countryPicker.delegate = self;

    self.index = 0;
    [self updateTitleLabel];
    [self setTappedCityTimer];
}

-(void)updateTitleLabel {
    NSString *country = [self.appModel getCountryData: self.index][@"name"];
    NSString *title = [NSString stringWithFormat:@"%@'s datetime:", country];
    self.titleLabel.text = title;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.appModel getCountryCount];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.appModel getCountryData: row][@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.index = row;
    [self updateTitleLabel];
    [self setTappedCityTimer];
}

-(void)setTappedCityTimer {
    [self.timer invalidate];
    self.timer = nil;

    [self setDateTimeLabelsWithTimeZone];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setDateTimeLabelsWithTimeZone) userInfo:nil repeats:YES];
}

-(void)setDateTimeLabelsWithTimeZone {
    NSArray *dateAndTime = [self formatCurrentDateTimeForTimeZone];
    self.timeLabel.text = dateAndTime[1];
    self.dateLabel.text = dateAndTime[0];
}

-(NSArray *)formatCurrentDateTimeForTimeZone {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSString *timezone = [self.appModel getCountryData: self.index][@"timezone"];
    NSTimeZone *localTimeZone = [NSTimeZone timeZoneWithAbbreviation: timezone];
    [dateFormatter setLocale:posix];
    [dateFormatter setDateFormat:@"EEEE MMMM dd y"];
    [dateFormatter setTimeZone:localTimeZone];
    [timeFormatter setLocale:posix];
    [timeFormatter setDateFormat:@"h:mm:ss a"];
    [timeFormatter setTimeZone:localTimeZone];

    NSDate *now = [NSDate date];
    NSString *date = [dateFormatter stringFromDate:now];
    NSString *time = [timeFormatter stringFromDate:now];

    NSArray *formattedDateAndTime = @[date, time];
    return formattedDateAndTime;
}

@end
