////
////  ViewController.m
////  AlarmClock
////
//
//
//#import "HomeViewController.h"
//#import "AppDelegate.h"
//
//@interface HomeViewController ()
//
//@property (nonatomic)UIAlertView *errorView;
//@property(nonatomic,assign) BOOL editMode;
//
//@end
//
//
//@implementation HomeViewController
//
//@synthesize hour1Label;
//@synthesize hour2Label;
//@synthesize minute1Label;
//@synthesize minute2Label;
//@synthesize colon1;
//@synthesize alarmGoingOff;
//
//@synthesize listOfAlarms;
//
//@synthesize timeToSetOff;
//@synthesize notificationID;
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    /* To receive messages when Robots connect & disconnect, set RMCore's delegate to self */
//    [RMCore setDelegate:self];
//    
//    if (!self.robot.connected) {
//        [self romoUnconnected];
//    }
//    
//    
//    /* Only one alarm supported right now. Always editMode. */
//    self.editMode = NO;
//    
//    [self myTimerAction];
//    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//    //How often to update the clock labels
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(myTimerAction) userInfo:nil repeats:YES];
//    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
//    [runloop addTimer:timer forMode:UITrackingRunLoopMode];
//    
//    
//    /* Edit mode is only true when an existing alarm is pressed. */
//    if (self.editMode)
//    {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSData *alarmListData = [defaults objectForKey:@"AlarmListData"];
//        NSMutableArray *alarmList = [NSKeyedUnarchiver unarchiveObjectWithData:alarmListData];
//        AlarmObject * oldAlarmObject = [alarmList objectAtIndex:self.indexOfAlarmToEdit];
//        //self.alarmLabel.text = oldAlarmObject.label;
//        if (oldAlarmObject.timeToSetOff == nil)
//            oldAlarmObject.timeToSetOff = [NSDate date];
//        timeToSetOff.date = oldAlarmObject.timeToSetOff;
//        self.notificationID = oldAlarmObject.notificationID;
//        self.listOfAlarms = alarmList;
//    }
//    
//}
//
//
//#define ALARM_FONT_SIZE 90
//- (void)viewWillAppear:(BOOL)animated
//{
//    //This is what sets the custom font
//    //See -http://stackoverflow.com/questions/360751/can-i-embed-a-custom-font-in-an-iphone-application
//    colon1.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
//    hour1Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
//    minute1Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
//    hour2Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
//    minute2Label.font = [UIFont fontWithName:@"digital-7" size:ALARM_FONT_SIZE];
//}
//
//-(void)viewDidAppear:(BOOL)animated
//{
//    //This checks if the home view is shown because of an alarm firing
//    //[self doAlarmActions];
//}
//
//
//
//- (void)doAlarmActions
//{
//    //if(self.alarmGoingOff)
//    {
//        UIAlertView *alarmAlert = [[UIAlertView alloc] initWithTitle:@"Romo Alarm"
//                                                             message:@"Stop the Madness"
//                                                            delegate:self
//                                                   cancelButtonTitle:@"Dismiss"
//                                                   otherButtonTitles:nil, nil];
//        [alarmAlert show];
//        
//        
//        /* Drive in a circle in place. */
//        [self alarmDriving];
//    }
//}
//
////This updates the clock labels
//-(void)myTimerAction
//{
//    NSDate *date = [NSDate date];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    NSString *hourMinuteSecond = [dateFormatter stringFromDate:date];
//    
//    if (colon1.hidden == NO) {
//        colon1.hidden = YES;
//    } else {
//        colon1.hidden = NO;
//    }
//    
//    hour1Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(0, 1)];
//    hour2Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(1, 1)];
//    minute1Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(3, 1)];
//    minute2Label.text = [hourMinuteSecond substringWithRange:NSMakeRange(4, 1)];
//}
//
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex == 0)
//    {
//        AppDelegate * myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [myAppDelegate.player stop];
//        
//        // If the robot is driving, let's stop driving
//        if (self.robot.isDriving) {
//            // Change the robot's LED to be solid at 80% power
//            [self.robot.LEDs setSolidWithBrightness:0.8];
//            
//            // Tell the robot to stop
//            [self.robot stopDriving];
//        }
//    }
//}
//
//
//
//
//
//#pragma mark -- RMCoreDelegate Methods --
//
//- (void)robotDidConnect:(RMCoreRobot *)robot
//{
//    // Currently the only kind of robot is Romo3, which supports all of these
//    //  protocols, so this is just future-proofing
//    if (robot.isDrivable && robot.isHeadTiltable && robot.isLEDEquipped) {
//        
//        self.robot = (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *) robot;
//        
//        // Change the robot's LED to be solid at 80% power
//        [self.robot.LEDs setSolidWithBrightness:0.8];
//        
//        
//        [self.errorView dismissWithClickedButtonIndex:0 animated:YES];
//    }
//}
//
//- (void)robotDidDisconnect:(RMCoreRobot *)robot
//{
//    if (robot == self.robot) {
//        self.robot = nil;
//        
//        [self romoUnconnected];
//    }
//}
//
//
//
//#pragma mark -- Robot Action Methods --
//
//- (void)alarmDriving
//{
//    /* Romo actions when alarm goes off. */
//    [self driveInCircle];
//    
//    /* Blink period */
//    float blinkPeriod = 2;
//    
//    /* Blink duty cycle */
//    float blinkDutyCycle = 0.8;
//    
//    [self.robot.LEDs blinkWithPeriod:blinkPeriod dutyCycle:blinkDutyCycle];
//}
//
//
//- (void)driveInCircle
//{
//    // Change the robot's LED to pulse
//    [self.robot.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
//    
//    // Romo's top speed is around 0.75 m/s
//    float speedInMetersPerSecond = 0.5;
//    
//    // Drive a circle about 0.25 meter in radius
//    //float radiusInMeters = 0.25;
//    
//    // Give the robot the drive command
//    [self.robot driveWithRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:speedInMetersPerSecond];
//}
//
//
//
//- (UIAlertView *)errorView
//{
//    if (!_errorView) {
//        _errorView = [[UIAlertView alloc]
//                      initWithTitle:NSLocalizedString(@"Romo Disconnected", @"Romo Disconnected")
//                      message:NSLocalizedString(@"This application requires a Romo to be connected.", @"Romo Disconnected")
//                      delegate:self
//                      cancelButtonTitle:nil
//                      otherButtonTitles:nil, nil];
//    }
//    return _errorView;
//}
//- (void)romoUnconnected
//{
//    //[self.errorView show];
//}
//
//
//
//
//# pragma mark -- Alarm Controls
//- (IBAction)didTouchEditAlarmButton:(UIButton *)sender {
//    if ([sender.currentTitle isEqualToString:@"Edit"]) {
//        [sender setTitle:@"Save" forState:UIControlStateNormal];
//        self.alarmSwitch.hidden = NO;
//        self.alarmLabel.hidden = NO;
//        self.timeToSetOff.hidden = NO;
//    } else {
//        [sender setTitle:@"Edit" forState:UIControlStateNormal];
//        self.alarmSwitch.hidden = NO;
//        self.alarmLabel.hidden = NO;
//        self.timeToSetOff.hidden = YES;
//        
//        [self saveAlarm:sender];
//    }
//}
//
//- (IBAction)didTouchSwitch:(UISwitch *)sender {
//    [self toggleAlarmEnabledSwitch:sender];
//}
//
//-(void)toggleAlarmEnabledSwitch:(id)sender
//{
//    UISwitch *mySwitch = (UISwitch *)sender;
//    
//    if(mySwitch.isOn == NO)
//    {
//        UIApplication *app = [UIApplication sharedApplication];
//        NSArray *eventArray = [app scheduledLocalNotifications];
//        AlarmObject *currentAlarm = [self.listOfAlarms objectAtIndex:mySwitch.tag];
//        currentAlarm.enabled = NO;
//        for (int i=0; i<[eventArray count]; i++)
//        {
//            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
//            NSDictionary *userInfoCurrent = oneEvent.userInfo;
//            NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"notificationID"]];
//            if ([uid isEqualToString:[NSString stringWithFormat:@"%li",(long)mySwitch.tag]])
//            {
//                //Cancelling local notification
//                [app cancelLocalNotification:oneEvent];
//                break;
//            }
//        }
//    }
//    else if(mySwitch.isOn == YES)
//    {
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        AlarmObject *currentAlarm = [self.listOfAlarms objectAtIndex:mySwitch.tag];
//        currentAlarm.enabled = YES;
//        if (!localNotification)
//            return;
//        
//        localNotification.repeatInterval = NSDayCalendarUnit;
//        [localNotification setFireDate:currentAlarm.timeToSetOff];
//        [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//        // Setup alert notification
//        [localNotification setAlertBody:@"Alarm" ];
//        [localNotification setAlertAction:@"Open App"];
//        [localNotification setHasAction:YES];
//        
//        
//        NSNumber* uidToStore = [NSNumber numberWithInt:currentAlarm.notificationID];
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:uidToStore forKey:@"notificationID"];
//        localNotification.userInfo = userInfo;
//        
//        
//        // Schedule the notification
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//    }
//    NSData *alarmListData2 = [NSKeyedArchiver archivedDataWithRootObject:self.listOfAlarms];
//    [[NSUserDefaults standardUserDefaults] setObject:alarmListData2 forKey:@"AlarmListData"];
//}
//
//
//
//-(IBAction)saveAlarm:(id)sender
//{
//    AlarmObject * newAlarmObject;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSData *alarmListData = [defaults objectForKey:@"AlarmListData"];
//    NSMutableArray *alarmList = [NSKeyedUnarchiver unarchiveObjectWithData:alarmListData];
//    
//    if(!alarmList)
//    {
//        alarmList = [[NSMutableArray alloc]init];
//    }
//    
//    /* Editing Alarm that already exists */
//    if(self.editMode)
//    {
//        newAlarmObject = [alarmList objectAtIndex:self.indexOfAlarmToEdit];
//        
//        [self CancelExistingNotification];
//    }
//    else//Adding a new alarm
//    {
//        newAlarmObject = [[AlarmObject alloc]init];
//        newAlarmObject.enabled = YES;
//        newAlarmObject.notificationID = [self getUniqueNotificationID];
//    }
//    
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"hh:mm a"];
//    
//    NSString *stringFromDate = [formatter stringFromDate:timeToSetOff.date];
//    stringFromDate = [NSString stringWithFormat:@"Alarm: %@", stringFromDate];
//    self.alarmLabel.text = stringFromDate;
//    
//    //newAlarmObject.label = self.alarmLabel.text;
//    newAlarmObject.timeToSetOff = timeToSetOff.date;
//    newAlarmObject.enabled = YES;
//    
//    //How often to update the clock labels
//    NSTimer *alarmTimer = [[NSTimer alloc] initWithFireDate:timeToSetOff.date
//                                                   interval:0.0
//                                                     target:self
//                                                   selector:@selector(doAlarmActions)
//                                                   userInfo:nil repeats:NO];
//    
//    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//    [runloop addTimer:alarmTimer forMode:NSDefaultRunLoopMode];
//    
//    [self scheduleLocalNotificationWithDate:self.timeToSetOff.date atIndex:newAlarmObject.notificationID];
//    
//    if(self.editMode == NO){
//        [alarmList addObject:newAlarmObject];
//        self.editMode = YES;
//    }
//    NSData *alarmListData2 = [NSKeyedArchiver archivedDataWithRootObject:alarmList];
//    [[NSUserDefaults standardUserDefaults] setObject:alarmListData2 forKey:@"AlarmListData"];
//    
//    
//}
//
//- (void)CancelExistingNotification
//{
//    //cancel alarm
//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *eventArray = [app scheduledLocalNotifications];
//    for (int i=0; i<[eventArray count]; i++)
//    {
//        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
//        NSDictionary *userInfoCurrent = oneEvent.userInfo;
//        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"notificationID"]];
//        if ([uid isEqualToString:[NSString stringWithFormat:@"%i",self.notificationID]])
//        {
//            /* Cancelling local notification */
//            [app cancelLocalNotification:oneEvent];
//            break;
//        }
//    }
//}
//
//
//- (void)scheduleLocalNotificationWithDate:(NSDate *)fireDate
//                                  atIndex:(int)indexOfObject {
//    
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    
//    
//    if (!localNotification)
//        return;
//    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh-mm -a";
//    NSDate* date = [dateFormatter dateFromString:[dateFormatter stringFromDate:timeToSetOff.date]];
//    
//    localNotification.repeatInterval = NSDayCalendarUnit;
//    [localNotification setFireDate:date];
//    [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//    // Setup alert notification
//    [localNotification setAlertBody:@"Alarm" ];
//    [localNotification setAlertAction:@"Open App"];
//    [localNotification setHasAction:YES];
//    
//    
//    NSLog(@"%@", date);
//    //This array maps the alarms uid to the index of the alarm so that we can cancel specific local notifications
//    
//    NSNumber* uidToStore = [NSNumber numberWithInt:indexOfObject];
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:uidToStore forKey:@"notificationID"];
//    localNotification.userInfo = userInfo;
//    NSLog(@"Uid Store in userInfo %@", [localNotification.userInfo objectForKey:@"notificationID"]);
//    
//    // Schedule the notification
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//    
//    
//}
//
////Get Unique Notification ID for a new alarm O(n)
//-(int)getUniqueNotificationID
//{
//    NSMutableDictionary * hashDict = [[NSMutableDictionary alloc]init];
//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *eventArray = [app scheduledLocalNotifications];
//    for (int i=0; i<[eventArray count]; i++)
//    {
//        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
//        NSDictionary *userInfoCurrent = oneEvent.userInfo;
//        NSNumber *uid= [userInfoCurrent valueForKey:@"notificationID"];
//        NSNumber * value =[NSNumber numberWithInt:1];
//        [hashDict setObject:value forKey:uid];
//    }
//    for (int i=0; i<[eventArray count]+1; i++)
//    {
//        NSNumber * value = [hashDict objectForKey:[NSNumber numberWithInt:i]];
//        if(!value)
//        {
//            return i;
//        }
//    }
//    return 0;
//    
//}
//
//
//
//
//@end
