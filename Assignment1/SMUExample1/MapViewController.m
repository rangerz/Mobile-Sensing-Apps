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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapLabel.text = _currentMap[@"name"];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake([_currentMap[@"latitude"] doubleValue], [_currentMap[@"longitude"] doubleValue])];
}

- (IBAction)handleClickGalleryButton:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[CollectionViewController class]];
    
    if(isVC){
        CollectionViewController *vc = [segue destinationViewController];
        vc.galleryNames = _currentMap[@"images"];
    }
    
}

@end
