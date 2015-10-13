//
//  FirstViewController.m
//  AssignApp
//
//  Created by optimusmac4 on 10/12/15.
//  Copyright © 2015 optimusmac4. All rights reserved.
//

#import "FirstViewController.h"
#import "MapPlotter.h"
#define kGoogleAPIKey @"AIzaSyBYor1WitGwUQ3BhcZxXzt7Iif6GWAQ-cI"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FirstViewController ()
{
    CLLocationCoordinate2D currentLocation;
    int currenDistance;
    BOOL firstLaunch;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _mapView.delegate=self;
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager startUpdatingLocation];
    
    
    _mapView.showsUserLocation = YES;
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
    firstLaunch=YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) searchContent: (NSString *)textToSearch {
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentLocation.latitude,currentLocation.longitude, [NSString stringWithFormat:@"%i", currenDistance], textToSearch, kGoogleAPIKey];
    NSLog(@"%@",url);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL asynchronously
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });}

// fetch JSON after API Hitting

-(void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* places = [json objectForKey:@"results"];
    //NSLog(@"Google Data: %@", places);
    [self mapPositionsPlot:places];
}

//called when user scrolls or zooms to give the new screen frames
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    MKMapRect mRect = self.mapView.visibleMapRect;  //get rectangular coordinates for the visible area on screen
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect)); // east most point
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect)); // west most point
    
    currenDistance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint); //distance b/w the points
    currentLocation = self.mapView.centerCoordinate;
}

// Plotting the positions on map i.e. adding annotation

-(void)mapPositionsPlot:(NSArray *)data {
    for (int i=0; i<[data count]; i++) {
        NSDictionary* place = [data objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        
        MapPlotter *placeObject = [[MapPlotter alloc] initWithName:name address:vicinity coordinate:placeCoord];
        [_mapView addAnnotation:placeObject];
    }
}

//adding customization to annotations
#pragma mark - MKMapViewDelegate methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MapPlotter";
    if ([annotation isKindOfClass:[MapPlotter class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        return annotationView;
    }
    return nil;
}

// Set region

-(void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    CLLocationCoordinate2D centre = [mv centerCoordinate];
    MKCoordinateRegion region;
    if (firstLaunch) {
        region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,1000,1000);
        firstLaunch=NO;
    }else {
        region = MKCoordinateRegionMakeWithDistance(centre,currenDistance,currenDistance);
    }
    [mv setRegion:region animated:YES];
}


#pragma IBAction outlets

- (IBAction)fetchBars:(id)sender {
    [self removeAnnotationsFromView];
    [self searchContent:@"bar"];
}
- (IBAction)fetchRestroBars:(id)sender {
    [self removeAnnotationsFromView];
    [self searchContent:@"bar"];
    [self searchContent:@"restaurant"];
}

#pragma Miscellaneous

-(void)removeAnnotationsFromView{
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPlotter class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }
}

@end
