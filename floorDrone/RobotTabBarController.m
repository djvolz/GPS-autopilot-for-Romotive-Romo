//
//  RobotTabBarController.m
//  floorDrone
//
//  Created by Danny Volz on 11/12/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//

#import "RobotTabBarController.h"

@interface RobotTabBarController ()

@property (nonatomic)UIAlertView *errorView;

@end

@implementation RobotTabBarController

#pragma mark -- RMCoreDelegate Methods --


- (void)robotDidConnect:(RMCoreRobot *)robot
{
    // Currently the only kind of robot is Romo3, which supports all of these
    //  protocols, so this is just future-proofing
    if (robot.isDrivable && robot.isHeadTiltable && robot.isLEDEquipped) {
        
        self.robot = (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *) robot;
        
        // Change the robot's LED to be solid at 80% power
        [self.robot.LEDs setSolidWithBrightness:0.8];
        
        [self.errorView dismissWithClickedButtonIndex:0 animated:YES];
        
        [self.robot tiltByAngle:INITIAL_HEAD_ANGLE
                     completion:nil];
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    if (robot == self.robot) {
        self.robot = nil;
        
        [self romoUnconnected];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // To receive messages when Robots connect & disconnect, set RMCore's delegate to self
    [RMCore setDelegate:self];
    
    /* Check to make sure the Romo is connected to the iPhone. */
    if (!self.robot.connected) {
        [self romoUnconnected];
    }
}

/* Alert if Romo is not connected. Disables the app from functioning. */
- (UIAlertView *)errorView
{
    if (!_errorView) {
        _errorView = [[UIAlertView alloc]
                      initWithTitle:NSLocalizedString(@"Romo Disconnected", @"Romo Disconnected")
                      message:NSLocalizedString(@"This application requires a Romo to be connected.", @"Romo Disconnected")
                      delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:nil, nil];
    }
    return _errorView;
}

- (void)romoUnconnected
{
   
    [self.errorView show];
}

- (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *)robot
{
    return _robot;
}

@end
