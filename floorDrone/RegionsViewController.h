//
//  RegionsViewController.h
//  floorDrone
//
//  Created by Danny Volz on 10/30/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"
#import <RMCharacter/RMCharacter.h>
#import "RobotTabBarController.h"


/* The specific threshold distances are determined by the hardware and the location
 * technologies that are currently available. For example, if Wi-Fi is disabled, 
 * region monitoring is significantly less accurate. However, for testing purposes, 
 * you can assume that the minimum distance is approximately 200 meters.
 */
#define RADIUS 30.0 //meters

@interface RegionsViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (retain, nonatomic) IBOutlet MKMapView *regionsMapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *updateEvents;
@property (strong, nonatomic) IBOutlet UIButton *driveButton;

- (void)checkLocationManager;
- (void)updateWithEvent:(NSString *)event;

@end
