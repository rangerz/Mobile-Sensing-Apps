//
//  MapViewController.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/30/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "CollectionViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (strong, nonatomic) NSDictionary *currentData;
@end

@implementation MapViewController

- (IBAction)changeControlMap:(id)sender {
    UISegmentedControl *s = (UISegmentedControl *)sender;
    
    switch (s.selectedSegmentIndex) {
        case 0:
            [_mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            [_mapView setMapType:MKMapTypeHybrid];
            break;
        case 2:
            [_mapView setMapType:MKMapTypeSatellite];
            break;
        default:
            break;
    }
}

-(void)setCountryData: (NSDictionary*)data {
    self.currentData = data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapLabel.text = self.currentData[@"name"];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.currentData[@"latitude"] doubleValue], [self.currentData[@"longitude"] doubleValue])];
}

- (IBAction)handleClickGalleryButton:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[CollectionViewController class]];
    
    if (isVC){
        CollectionViewController *vc = [segue destinationViewController];
        [vc setImageNames: self.currentData[@"images"]];
    }
}

@end
