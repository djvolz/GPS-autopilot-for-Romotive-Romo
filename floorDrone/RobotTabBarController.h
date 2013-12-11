//
//  RobotTabBarController.h
//  floorDrone
//
//  Created by Danny Volz on 11/12/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMCore/RMCore.h>

#define INITIAL_HEAD_ANGLE 130.0

@interface RobotTabBarController : UITabBarController <RMCoreDelegate>

@property (nonatomic, strong) RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot;


@end
