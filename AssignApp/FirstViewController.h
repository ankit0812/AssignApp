//
//  FirstViewController.h
//  AssignApp
//
//  Created by optimusmac4 on 10/12/15.
//  Copyright © 2015 optimusmac4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (IBAction)fetchRestroBars:(id)sender;

@end

