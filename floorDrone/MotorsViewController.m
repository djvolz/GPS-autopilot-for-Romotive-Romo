//
//  MotorsViewController.m
//  floorDrone
//
//  Created by Danny Volz on 10/30/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//

#import "MotorsViewController.h"

@interface MotorsViewController ()

@property (nonatomic)double tiltAngle;
@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic, readonly) RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot;
@property (nonatomic, strong) RMCharacter *romo;
@property (weak, nonatomic) IBOutlet UIView *romoView;

@end


@implementation MotorsViewController

- (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *)robot
{
    if ([[self tabBarController] respondsToSelector:@selector(robot)]) {
        RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot = [[self tabBarController] performSelector:@selector(robot)];
        
        return  robot;
    }
    
    return nil;
}

#pragma mark -- View Lifecycle --

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Grab a shared instance of the Romo character
    self.romo = [RMCharacter Romo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tiltAngleSlider setValue:INITIAL_HEAD_ANGLE animated:YES];
    self.tiltAngle = INITIAL_HEAD_ANGLE;
    self.angleLabel.text = [NSString stringWithFormat:@"Angle: %iº", (int)INITIAL_HEAD_ANGLE];
}

- (void)setTiltAngle:(double)tiltAngle
{
    /* Tilt angle is based off of the iPhone's accelerometer.
     * Thus it assumes that the Romo is on a level surface.
     */
    
    _tiltAngle = tiltAngle;
    self.angleLabel.text = [NSString stringWithFormat:@"Angle: %dº", (int)tiltAngle];
}


#pragma mark -- IBAction Methods --

- (IBAction)didSlideTiltAngleSlider:(UISlider *)sender {
    
    [self.robot tiltToAngle:sender.value
                 completion:^(BOOL success) {
                     // Reset button title on the main queue
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self setTiltAngle:self.tiltAngleSlider.value];
                     });
                 }];
    
    /* Head angle between 70 and 130 degrees. Speed is between 0.2ms and 0.75ms. 
     * This relation was created to use the head angle read from the accelerometer
     * in order to determine the Romo's speed. Speed can be between ~0.35-0.7ms in this mode.
     */
    double speed = self.robot.headAngle;
    speed /= 70; // Mininmum tilt angle
    speed *= 0.35; // Multiplier value
    self.speedSlider.value = speed;
    self.speedLabel.text = [NSString stringWithFormat:@"Speed: %0.2fm/s", speed];
}


- (IBAction)didTouchDriveButton:(UIButton *)sender {
    // If the robot is driving, let's stop driving
    if (self.robot.isDriving) {
        // Change the robot's LED to be solid at 80% power
        [self.robot.LEDs setSolidWithBrightness:0.5];
        
        // Tell the robot to stop
        [self.robot stopDriving];
        
        [sender setTitle:@"Begin Driving" forState:UIControlStateNormal];
    } else {
        // Change the robot's LED to pulse
        [self.robot.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
        
        // Romo's top speed is around 0.75 m/s
        float speedInMetersPerSecond = self.speedSlider.value;
        
        // Give the robot the drive command
        [self.robot driveBackwardWithSpeed:speedInMetersPerSecond];
        
        /* Change button to reflect the action it now provides. */
        [sender setTitle:@"Stop Driving" forState:UIControlStateNormal];
        
        
        /* Used to calculate length of time Romo should drive. */
        NSTimeInterval driveTime = self.distanceSlider.value / self.speedSlider.value;
        
        /* Drive for specified time.
         * This should make the Romo go the correct distance assuming a
         * smooth flat surface.
         */
        [self performSelector:@selector(endDriving) withObject:nil afterDelay:driveTime];
    }
}

- (IBAction)didSlideSpeedSlider:(UISlider *)sender {
    self.speedLabel.text = [NSString stringWithFormat:@"Speed: %0.2fm/s", sender.value];
}

- (IBAction)didSlideDistanceSlider:(UISlider *)sender {
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %1.1f meters", sender.value];
}

- (IBAction)didChangeSegmentedControl:(UISegmentedControl *)sender {
    
    NSInteger selectedSegment = self.modeSelectorSegmentedControl.selectedSegmentIndex;
    
    /* Toggle tilt control mode. */
    if (selectedSegment == 0) {
        self.speedSlider.hidden = YES;
        self.speedLabel.hidden = YES;
        self.angleLabel.hidden = NO;
        self.tiltAngleSlider.hidden = NO;
        
        /* These buttons can be moved to a view later so be hidden all at once. */
        self.northButton.hidden = YES;
        self.eastButton.hidden = YES;
        self.southButton.hidden = YES;
        self.westButton.hidden = YES;
        
    /* Toggle slider control mode. */
    } else {
        self.speedSlider.hidden = NO;
        self.speedLabel.hidden = NO;
        self.angleLabel.hidden = YES;
        self.tiltAngleSlider.hidden = YES;
        
        /* These buttons can be moved to a view later so be hidden all at once. */
        self.northButton.hidden = NO;
        self.eastButton.hidden = NO;
        self.southButton.hidden = NO;
        self.westButton.hidden = NO;
    }
}


- (IBAction)didTouchDirectionButton:(UIButton *)sender {
    
    /* This causes the robot to turn towards a cardinal direction and begin driving
     * if the distance slider is above 0.
     */
    if ([sender isEqual:self.northButton]) {
        [self turnToHeading:NORTH];
    } else if ([sender isEqual:self.eastButton]) {
        [self turnToHeading:EAST];
    } else if ([sender isEqual:self.southButton]) {
        [self turnToHeading:SOUTH];
    } else if ([sender isEqual:self.westButton]) {
        [self turnToHeading:WEST];
    }
}

/* Swiping up on the Romo Character will remove the character. */
- (IBAction)didSwipeUpOnRomoView:(UISwipeGestureRecognizer *)sender {
    /* Removing Romo from the superview stops animations and sounds. */
    [self.romo removeFromSuperview];
    
    /* Hide the Romo Character view and return to drive controls. */
    self.romoView.hidden = YES;
}



#pragma mark - Romo Action elements

/* Performs the tilting action. */
- (void)doTilt:(UIButton *)sender byAngle:(float)angle withTitle:(NSString *)title
{
    // If the robot is tilting, stop tilting
    if (self.robot.isTilting) {
        
        // Tell the robot to stop tilting
        [self.robot stopTilting];
        
        [sender setTitle:title forState:UIControlStateNormal];
        
    } else {
        
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        
        
        [self.robot tiltByAngle:angle
                     completion:^(BOOL success) {
                         // Reset button title on the main queue
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [sender setTitle:title forState:UIControlStateNormal];
                         });
                     }];
    }
}


/* This function turns to the inputted heading and selects the Begin Driving button. */
- (void)turnToHeading:(float)heading
{
    [self.robot turnToHeading:heading
                   withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE
              finishingAction:RMCoreTurnFinishingActionStopDriving
                   completion:^(float heading){
                       [self.driveButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                   }];
}

- (void)endDriving
{
    // Change the robot's LED to be solid at 80% power
    [self.robot.LEDs setSolidWithBrightness:0.5];
    
    // Tell the robot to stop
    [self.robot stopDriving];
    
    /* Reset the button text. */
    [self.driveButton setTitle:@"Begin Driving" forState:UIControlStateNormal];
    
    /* Take a picture when the destination is reached. */
    [self takePicture:nil];
    
    /* Display the Romo character when the destination is reached. */
    [self displayRomoCharacter];
    
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
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:3.0];
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