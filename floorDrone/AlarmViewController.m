//
//  AlarmViewController
//  floorDrone
//
//  Created by Danny Volz on 10/30/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//


#import "AlarmViewController.h"

@interface AlarmViewController ()

@property (nonatomic)NSTimer *alarmTimer;
@property (nonatomic, readonly) RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot;


@end

@implementation AlarmViewController

@synthesize hour1Label;
@synthesize hour2Label;
@synthesize minute1Label;
@synthesize minute2Label;
@synthesize colon1;
@synthesize player;
@synthesize timeToSetOff;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self myTimerAction];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    
    //How often to update the clock labels
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(myTimerAction) userInfo:nil repeats:YES];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:timer forMode:UITrackingRunLoopMode];
}


#define ALARM_FONT_SIZE 90
- (void)viewWillAppear:(BOOL)animated
{
    //This is what sets the custom font
    //See -http://stackoverflow.com/questions/360751/can-i-embed-a-custom-font-in-an-iphone-application
    colon1.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
    hour1Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
    minute1Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
    hour2Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
    minute2Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
}



- (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *)robot
{
    if ([[self tabBarController] respondsToSelector:@selector(robot)]) {
        RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot = [[self tabBarController] performSelector:@selector(robot)];
        
        return  robot;
    }
    
    return nil;
}



/* This function performs the alarm actions.
 * 1) Show alert prompting alarm to be dismissed.
 * 2) Begin playing music.
 * 3) Make the Romo turn in circles.
 *
 *  Definitely should wake you up.
 */
- (void)doAlarmActions
{
    UIAlertView *alarmAlert = [[UIAlertView alloc] initWithTitle:@"Romo Alarm"
                                                         message:@"Stop the Madness"
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil, nil];
    [alarmAlert show];
    
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Best_Morning_Alarm" ofType:@"m4r"];
    
        NSURL *file = [[NSURL alloc] initFileURLWithPath:path];
    
        self.player =[[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
        [self.player prepareToPlay];
        [self.player play];
    
    /* Drive in a circle in place. */
    [self alarmDriving];
}

/* This updates the clock labels. */
-(void)myTimerAction
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *hourMinuteSecond = [dateFormatter stringFromDate:date];
    
    if (colon1.hidden == NO) {
        colon1.hidden = YES;
    } else {
        colon1.hidden = NO;
    }

    hour1Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(0, 1)];
    hour2Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(1, 1)];
    minute1Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(3, 1)];
    minute2Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(4, 1)];
    
    if (![self.alarmLabel.text isEqualToString:@"Alarm: Not Set"]) {
        double seconds = [self calculateTimeDifference];
        self.timeDifferenceLabel.text = [NSString stringWithFormat:@"Minutes until Alarm: %d", (int)seconds/60];
    }
}


/* Stops the alarm. 
 * Stops the music. 
 * Stops the alert. 
 * Stops the driving. 
 * Stops the madness. 
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        // If the robot is driving, let's stop driving
        if (self.robot.isDriving) {
            // Change the robot's LED to be solid at 80% power
            [self.robot.LEDs setSolidWithBrightness:0.8];
            
            /* Stop the music. */
            [self.player stop];
            
            /* Tell the robot to stop. */
            [self.robot stopDriving];
            
            /* Switch off the alarm switch. */
            [self.alarmSwitch setOn:NO animated:YES];
        }
    }
}



#pragma mark -- Robot Action Methods --

- (void)alarmDriving
{
    /* Romo actions when alarm goes off. */
    [self driveInCircle];
    
    /* Blink period */
    float blinkPeriod = 2;
    
    /* Blink duty cycle */
    float blinkDutyCycle = 0.8;
    
    [self.robot.LEDs blinkWithPeriod:blinkPeriod dutyCycle:blinkDutyCycle];
}

/* Makes the romo turn in place in a circle. */
- (void)driveInCircle
{
    // Romo's top speed is around 0.75 m/s
    float speedInMetersPerSecond = 0.5;
    
    // Give the robot the drive command
    [self.robot driveWithRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:speedInMetersPerSecond];
}


# pragma mark -- Alarm Controls

- (void)createAlarm
{
    
    /* Create the alarm timer. */
    self.alarmTimer = [[NSTimer alloc] initWithFireDate:timeToSetOff.date
                                               interval:0.0
                                                 target:self
                                               selector:@selector(doAlarmActions)
                                               userInfo:nil repeats:NO];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:self.alarmTimer forMode:NSDefaultRunLoopMode];
}

- (IBAction)didTouchEditAlarmButton:(UIButton *)sender {
    
    /* Edit the alarm. Show the date picker. */
    if ([sender.currentTitle isEqualToString:@"Edit"]) {
        [sender setTitle:@"Save" forState:UIControlStateNormal];
        self.timeToSetOff.hidden = NO;
        self.alarmSwitch.hidden = YES;
        self.alarmLabel.hidden = YES;
        
    /* Save the alarm and hide date picker. */
    } else {
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        self.timeToSetOff.hidden = YES;
        self.alarmSwitch.hidden = NO;
        self.alarmLabel.hidden = NO;
        
        /* Create a date formatter that displays hours and minutes. */
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        
        /* Display the desired alarm time. */
        NSString *stringFromDate = [formatter stringFromDate:timeToSetOff.date];
        stringFromDate = [NSString stringWithFormat:@"Alarm: %@", stringFromDate];
        self.alarmLabel.text = stringFromDate;
        
        /* Update the countdown label. */
        double seconds = [self calculateTimeDifference];
        self.timeDifferenceLabel.text = [NSString stringWithFormat:@"Minutes until Alarm: %d", (int)seconds/60];
        
        /* If the alarm switch is on, then make the alarm. */
        if (self.alarmSwitch.isOn == YES) {
            [self createAlarm];
        }
    }
}

/* Calculates the time difference between two dates. Returns a time interval. */
- (NSTimeInterval)calculateTimeDifference
{
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeDifference = [self.timeToSetOff.date timeIntervalSinceDate:currentDate];
    
    return timeDifference;
}

- (IBAction)didTouchSwitch:(UISwitch *)sender {
    if(sender.isOn == NO)
    {
        /* Cancel the alarm. */
        [self.alarmTimer invalidate];
        
        /* Hide the countdown label. */
        self.timeDifferenceLabel.hidden = YES;
    }
    else if(sender.isOn == YES)
    {
        /* Setup the alarm. */
        [self createAlarm];
        
        /* Display the countdown label. */
        self.timeDifferenceLabel.hidden = NO;
    }
}


@end
