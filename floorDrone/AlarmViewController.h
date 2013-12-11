//
//  AlarmViewController.h
//  floorDrone
//
//  Created by Danny Volz on 10/30/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RobotTabBarController.h"
//#import "AlarmObject.h"

@interface AlarmViewController : UIViewController<UIAlertViewDelegate>

@property(strong, nonatomic) IBOutlet UILabel * hour1Label;
@property(strong, nonatomic) IBOutlet UILabel * hour2Label;
@property(strong, nonatomic) IBOutlet UILabel * minute1Label;
@property(strong, nonatomic) IBOutlet UILabel * minute2Label;
@property(strong, nonatomic) IBOutlet UILabel * colon1;

@property (weak, nonatomic) IBOutlet UILabel *timeDifferenceLabel;
@property (weak, nonatomic) IBOutlet UIButton *editAlarm;
@property (weak, nonatomic) IBOutlet UILabel *alarmLabel;
@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;

@property (nonatomic, strong) IBOutlet UIDatePicker *timeToSetOff;

- (void)doAlarmActions;

@property (nonatomic, strong) AVAudioPlayer *player;

@end
