//
//  RegionsViewController.m
//  floorDrone
//
//  Created by Danny Volz on 10/30/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//

#import "RegionsViewController.h"

@interface RegionsViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic)CGFloat angleBetweenCoordinates;
@property (weak, nonatomic) IBOutlet UILabel *desiredHeadingLabel;
@property (strong, nonatomic) IBOutlet UILabel *deviceHeadingLabel;
@property (nonatomic)MKUserLocation *userLoc;
@property (strong, nonatomic) IBOutlet UISwitch *allowDriving;
@property (strong, nonatomic) IBOutlet UISwitch *useRomoCompassTurningSwitch;

/* Sorted annotations is used because the maps annotations array isn't sorted and includes the user's location. */
@property (nonatomic)NSMutableArray *sortedAnnotations;

@property (nonatomic, readonly) RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot;
@property (nonatomic, strong) RMCharacter *romo;
@property (weak, nonatomic) IBOutlet UIView *romoView;

@end

@implementation RegionsViewController

@synthesize regionsMapView, updateEvents, locationManager;



- (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *)robot
{
    if ([[self tabBarController] respondsToSelector:@selector(robot)]) {
        RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot = [[self tabBarController] performSelector:@selector(robot)];
        
        return  robot;
    }
    
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortedAnnotations = [[NSMutableArray alloc] init];
    
    // Grab a shared instance of the Romo character
    self.romo = [RMCharacter Romo];
    
    
    self.regionsMapView.delegate = self;
	
	// Create empty array to add region events to.
	updateEvents = [[NSMutableArray alloc] initWithCapacity:0];
	
	// Create location manager with filters set for battery efficiency.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLLocationAccuracyBest;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Start updating location changes.
	[locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = 6;
        [locationManager startUpdatingHeading];
    }
    
    [self checkLocationManager];
    
    
    /* Add a long press gesture for pin drops. */
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 1 seconds
    [self.regionsMapView addGestureRecognizer:lpgr];
}


- (void)viewDidAppear:(BOOL)animated {
//	// Get all regions being monitored for this application.
//	NSArray *regions = [[locationManager monitoredRegions] allObjects];
//	
//	// Iterate through the regions and add annotations to the map for each of them.
//	for (int i = 0; i < [regions count]; i++) {
//		CLRegion *region = [regions objectAtIndex:i];
//		RegionAnnotation *annotation = [[RegionAnnotation alloc] initWithCLRegion:region];
//		[regionsMapView addAnnotation:annotation];
//	}
}


- (void)viewDidUnload {
	self.updateEvents = nil;
	self.locationManager.delegate = nil;
	self.locationManager = nil;
	self.regionsMapView = nil;
}


#pragma mark - MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userLoc = userLocation;
    
    /* Sorted annotations is used because the maps annotations array isn't sorted and includes the user's location. */
    RegionAnnotation *lastAnnotation = [self.sortedAnnotations lastObject];
    NSNumber *currentLocationDistance = [self calculateDistanceInMetersBetweenCoord:userLocation.coordinate coord:lastAnnotation.coordinate];
    if([currentLocationDistance floatValue] < RADIUS) {
        [self locationManager:locationManager didEnterRegion:lastAnnotation.region];
        
        NSUInteger indexOfAnnotation = [self.regionsMapView.annotations indexOfObject:lastAnnotation];
        RegionAnnotation *regionAnnotation = [self.regionsMapView.annotations objectAtIndex:indexOfAnnotation];
        NSString *annotationIdentifier = [regionAnnotation title];
        RegionAnnotationView *regionView = (RegionAnnotationView *)[regionsMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!regionView) {
			regionView = [[RegionAnnotationView alloc] initWithAnnotation:regionAnnotation];
			regionView.map = regionsMapView;
        }
        
        // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
        [locationManager stopMonitoringForRegion:regionAnnotation.region];
        [regionView removeRadiusOverlay];
        [regionsMapView removeAnnotation:regionAnnotation];
        [self.sortedAnnotations removeObject:regionAnnotation];
        
        /* End driving with success. */
        [self endDriving:YES];
        
        /* Calculate new heading. */
        [self calculateAngleBegtweenCoordinates];
    }
    

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    if (newHeading.headingAccuracy < 15)
        return;

    if (self.allowDriving.isOn) {
        if (self.robot.isDriving) {
            [self endDriving:NO];
        }
        
        if ([self.sortedAnnotations lastObject] != nil) {
            [self turnToHeading:self.angleBetweenCoordinates];
        }
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if([annotation isKindOfClass:[RegionAnnotation class]]) {
		RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
		NSString *annotationIdentifier = [currentAnnotation title];
		RegionAnnotationView *regionView = (RegionAnnotationView *)[regionsMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!regionView) {
			regionView = [[RegionAnnotationView alloc] initWithAnnotation:annotation];
			regionView.map = regionsMapView;
			
			// Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
			UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
            
			regionView.leftCalloutAccessoryView = removeRegionButton;
		} else {
			regionView.annotation = annotation;
			regionView.theAnnotation = annotation;
		}
		
		// Update or add the overlay displaying the radius of the region around the annotation.
		[regionView updateRadiusOverlay];
        
		return regionView;
	}
	
    
    
	return nil;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKCircle class]]) {
		// Create the view for the radius overlay.
		MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
		circleView.strokeColor = [UIColor purpleColor];
		circleView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];
		
		return circleView;
	}
	
	return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if([annotationView isKindOfClass:[RegionAnnotationView class]]) {
		RegionAnnotationView *regionView = (RegionAnnotationView *)annotationView;
		RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
		
		// If the annotation view is starting to be dragged, remove the overlay and stop monitoring the region.
		if (newState == MKAnnotationViewDragStateStarting) {
			[regionView removeRadiusOverlay];
			
			[locationManager stopMonitoringForRegion:regionAnnotation.region];
		}
		
		// Once the annotation view has been dragged and placed in a new location, update and add the overlay and begin monitoring the new region.
		if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
			[regionView updateRadiusOverlay];
            
            CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:regionAnnotation.coordinate radius:RADIUS identifier:[NSString stringWithFormat:@"%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude]];
            
			regionAnnotation.region = newRegion;
			
			[locationManager startMonitoringForRegion:regionAnnotation.region];
		}
        
        [self calculateAngleBegtweenCoordinates];
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	RegionAnnotationView *regionView = (RegionAnnotationView *)view;
	RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
	
	// Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
	[locationManager stopMonitoringForRegion:regionAnnotation.region];
	[regionView removeRadiusOverlay];
	[regionsMapView removeAnnotation:regionAnnotation];
    [self.sortedAnnotations removeObject:regionAnnotation];
    
    /* End driving without success. */
    [self endDriving:NO];
    
    [self calculateAngleBegtweenCoordinates];
}


#pragma mark - CLLocationManagerDelegate

- (void) checkLocationManager
{
    if(![CLLocationManager locationServicesEnabled])
    {
        [self showMessage:@"You need to enable Location Services"];
        //        return  FALSE;
    }
    if(![CLLocationManager isMonitoringAvailableForClass:CLCircularRegion.class])
    {
        [self showMessage:@"Region monitoring is not available for this Class"];
        //        return  FALSE;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        [self showMessage:@"You need to authorize Location Services for the APP"];
        //        return  FALSE;
    }
    //    return TRUE;
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
    
    
	/* Zooms to initial user location. */
	if (oldLocation == nil) {
        [self zoomToUserLocation];
	}
}

- (void)zoomToUserLocation
{
    // Zoom to the current user location.
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(self.userLoc.coordinate, 500.0, 500.0);
    [regionsMapView setRegion:userLocation animated:YES];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
	
    //[self showMessage:event];
    //[self endDriving:YES];
    
	[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
	//[self showMessage:event];
    
    //[self endDriving:YES];
    
	[self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
	
	[self updateWithEvent:event];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside) {
        //NSString *event = [NSString stringWithFormat:@"Did Enter Region %@", region.identifier];
        //[self showMessage:event];
        //[self endDriving:YES];
        NSLog(@"##Entered Region - %@", region.identifier);
    } else if(state == CLRegionStateOutside) {
        //NSString *event = [NSString stringWithFormat:@"Did Exit Region %@", region.identifier];
        //[self showMessage:event];
        NSLog(@"##Exited Region - %@", region.identifier);
    } else{
        NSLog(@"##Unknown state  Region - %@", region.identifier);
    }
}



#pragma mark - RegionsViewController

/*
 This method creates a new region based on the touched coordinate of the map view.
 A new annotation is created to represent the region and then the application starts monitoring the new region.
 */
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.regionsMapView];
    CLLocationCoordinate2D coord = [regionsMapView convertPoint:touchPoint toCoordinateFromView:regionsMapView];
    
	if ([CLLocationManager isMonitoringAvailableForClass:CLCircularRegion.class]) {
		// Create a new region based on the center of the map view.
		CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coord
																	  radius:RADIUS
																  identifier:[NSString stringWithFormat:@"%f, %f", regionsMapView.centerCoordinate.latitude, regionsMapView.centerCoordinate.longitude]];
		
        newRegion.notifyOnEntry = YES;
        
		// Create an annotation to show where the region is located on the map.
		RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
		myRegionAnnotation.coordinate = newRegion.center;
		myRegionAnnotation.radius = newRegion.radius;
		
		[regionsMapView addAnnotation:myRegionAnnotation];
        
        [self.sortedAnnotations addObject:myRegionAnnotation];
		
		// Start monitoring the newly created region.
		[self.locationManager startMonitoringForRegion:newRegion];
        
        [self calculateAngleBegtweenCoordinates];
        
	}
	else {
		NSLog(@"Region monitoring is not available.");
	}
}


/*
 * Only used for testing.
 * This method adds the region event to the events array and updates the icon badge number.
 * Icon badge numbers are disabled.
 */
- (void)updateWithEvent:(NSString *)event {
	// Add region event to the updates array.
	[updateEvents insertObject:event atIndex:0];
	
	// Update the icon badge number.
	//[UIApplication sharedApplication].applicationIconBadgeNumber++;
}


#pragma mark -- Helper Functions --


- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    
    // convert to meters
    return @(nD*1000);
}

- (void)calculateAngleBegtweenCoordinates
{
    if (self.sortedAnnotations.lastObject != nil) {
        /* Sorted annotations is used because the maps annotations array isn't sorted and includes the user's location. */
        RegionAnnotation *lastAnnotation = [self.sortedAnnotations lastObject];
        
        
        CGFloat deltaY = lastAnnotation.coordinate.longitude - self.userLoc.coordinate.longitude;
        CGFloat deltaX = lastAnnotation.coordinate.latitude - self.userLoc.coordinate.latitude;
        
        CGFloat angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI;
        
        NSLog(@"angleInDegrees: %f", angleInDegrees);
        
        self.angleBetweenCoordinates = angleInDegrees;
    } else {
        NSLog(@"No Geofences");
    }
    
    
    /* User info. Let them know the heading of the last pin drop. */
    NSString *desiredHeadingString = [NSString stringWithFormat:@"Desired Heading: %f", self.angleBetweenCoordinates];
    self.desiredHeadingLabel.text = desiredHeadingString;
    
    
    NSString *deviceHeadingString = [NSString stringWithFormat:@"Device Heading: %f", self.locationManager.heading.trueHeading];
    self.deviceHeadingLabel.text = deviceHeadingString;
}

- (void) showMessage:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Geofence"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:Nil, nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
}


- (void)turnToHeading:(float)heading
{
    /* Ensure that the iPhone is tilted correctly for compass measurements. */
    if ((INITIAL_HEAD_ANGLE - 10) < self.robot.headAngle < (INITIAL_HEAD_ANGLE + 10)) {
        [self.robot tiltByAngle:INITIAL_HEAD_ANGLE
                     completion:nil];
    }
    
    float deviceHeading = self.locationManager.heading.trueHeading;
    
    
    NSString *desiredHeadingString = [NSString stringWithFormat:@"Desired Heading: %f", heading];
    self.desiredHeadingLabel.text = desiredHeadingString;
    
    NSString *deviceHeadingString = [NSString stringWithFormat:@"Device Heading: %f", deviceHeading];
    self.deviceHeadingLabel.text = deviceHeadingString;
    
    
    
    /* For some reason, the turnToHeading function in the Romo API isn't always correct
     * so I wrote my own function above that draws straight from the iPhone's compass
     * in order to calculate the angle to turn by.
     */
    if (self.useRomoCompassTurningSwitch.isOn) {
        /* The robot uses heading correctly in quadrants 1 and 3. */
        float correctedHeading;
        if ((0 < heading < 90) || (-90 > heading > -179)) {
            correctedHeading =  -heading;
            
            /* The robot drives the opposite directions in quadrants 2 and 4.
             * Thus the heading is negated for these quadrants to correct this problem.
             */
        } else {
            correctedHeading = heading;
        }
        
        [self.robot turnToHeading:correctedHeading
                       withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE
                  finishingAction:RMCoreTurnFinishingActionStopDriving
                       completion:^(float heading){
                           [self.driveButton setTitle:@"Stop Driving" forState:UIControlStateNormal];
                           [self.robot driveBackwardWithSpeed:0.75];
                       }];
    } else {
        /* Converts device's heading which is [0,360] degrees to Romo's desired [-180,180] degrees. */
        if (deviceHeading > 180.0) {
            float difference =  deviceHeading - 180;
            difference = 180 - difference;
            deviceHeading = -difference;
        }
        
        //        float headingError;
        //        if (deviceHeading > heading) {
        //            headingError = deviceHeading - heading;
        //        } else {
        //            headingError = heading - deviceHeading;
        //        }
        //        while (headingError > 10.0) {
        //
        //            if (deviceHeading > 180.0) {
        //                float difference =  deviceHeading - 180;
        //                difference = 180 - difference;
        //                deviceHeading = -difference;
        //            }
        
        /* Calculate the desired angle to turn by, based on the current heading
         * and the desired heading.
         */
        float angleToTurn = -(heading - deviceHeading);
        
        [self.robot turnByAngle:angleToTurn withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE completion:^(float heading){
            [self.driveButton setTitle:@"Stop Driving" forState:UIControlStateNormal];
            [self.robot driveBackwardWithSpeed:0.75];
        }];
        
    }
    
}


- (void)endDriving:(BOOL)withSuccess
{
    // Change the robot's LED to be solid at 80% power
    [self.robot.LEDs setSolidWithBrightness:0.5];
    
    // Tell the robot to stop
    [self.robot stopDriving];
    
    /* Reset the button text. */
    [self.driveButton setTitle:@"Begin Driving" forState:UIControlStateNormal];
    
    /* If Romo view is currently being displayed, don't display another. */
    if ((withSuccess) && (self.romoView.hidden = YES)) {
        /* Display the Romo character when the destination is reached. */
        [self displayRomoCharacter];
        
        /* Take a picture when the destination is reached. */
        [self takePicture:nil];
    }
    
}


- (IBAction)didTouchDriveButton:(UIButton *)sender {
    
    [sender setTitle:@"Begin Driving" forState:UIControlStateNormal];
    
    // If the robot is driving, let's stop driving
    if (self.robot.isDriving) {

        [self endDriving:NO];
        
    } else {
        // Change the robot's LED to pulse
        [self.robot.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
        
        // Romo's top speed is around 0.75 m/s
        float speedInMetersPerSecond = 0.75;
        
        // Give the robot the drive command
        [self.robot driveForwardWithSpeed:speedInMetersPerSecond];
        
        /* Change button to reflect the action it now provides. */
        [sender setTitle:@"Stop Driving" forState:UIControlStateNormal];
        
        if ([self.sortedAnnotations lastObject] != nil) {
            [self turnToHeading:self.angleBetweenCoordinates];
        }
    }
}



#pragma mark - UI Elements

/* An excited Romo character appears when the destination is reached. */
- (void)displayRomoCharacter
{
    self.romoView.hidden = NO;
    
    // Add Romo's face to self.view whenever the view will appear
    [self.romo addToSuperview:self.romoView];
    [self.romo setExpression:RMCharacterExpressionExcited withEmotion:RMCharacterEmotionExcited];
}

/* Swiping up on the Romo Character will remove the character. */
- (IBAction)didSwipeUpOnRomoView:(UISwipeGestureRecognizer *)sender {
    /* Removing Romo from the superview stops animations and sounds. */
    [self.romo removeFromSuperview];
    
    /* Hide the Romo Character view and return to drive controls. */
    self.romoView.hidden = YES;
}

- (IBAction)didTouchZoomButton:(UIButton *)sender {
    [self zoomToUserLocation];
}

#pragma mark - Photo Handler

-(void) takePicture:(id) sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    /* The user wants to use the camera interface.
     * Set up without manual controls for the camera.
     */
    imagePicker.showsCameraControls = NO;
    
    [imagePicker setDelegate:self];
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    self.imagePickerController = imagePicker;
    
    /* Picture taking is delayed.
     * Since picture taking is automatic, the camera needs time to initialize
     * before a photo can be taken.
     */
    [self presentViewController:self.imagePickerController animated:YES completion:^(void){
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:4.0];
        NSTimer *cameraTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:1.0 target:self selector:@selector(timedPhotoFire:) userInfo:nil repeats:NO];
        
        [[NSRunLoop mainRunLoop] addTimer:cameraTimer forMode:NSDefaultRunLoopMode];
    }];
}

/* Called by the timer to take a picture. */
- (void)timedPhotoFire:(NSTimer *)timer
{
    [self.imagePickerController takePicture];
}

/* Save the photo to the photo library. */
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *finalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    /* Remove the camera view. */
    [self dismissViewControllerAnimated:NO completion:nil];
    
    /* Save photo to library. */
    UIImageWriteToSavedPhotosAlbum(finalImage, self, nil, nil);
}


@end
