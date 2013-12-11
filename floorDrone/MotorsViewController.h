//
//  MotorsViewController.h
//  floorDrone
//
//  Created by Danny Volz on 10/30/13.
//  Copyright (c) 2013 Rice University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMCharacter/RMCharacter.h>
#import "RobotTabBarController.h"

#define NORTH   0
#define EAST    -90
#define SOUTH   180
#define WEST    90

@interface MotorsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// UI
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeSelectorSegmentedControl;

/* Sliders */
@property (strong, nonatomic) IBOutlet UISlider *tiltAngleSlider;
@property (strong, nonatomic) IBOutlet UISlider *speedSlider;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;

/* Labels */
@property (strong, nonatomic) IBOutlet UILabel *angleLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *driveButton;

@property (strong, nonatomic) IBOutlet UIButton *northButton;
@property (strong, nonatomic) IBOutlet UIButton *eastButton;
@property (strong, nonatomic) IBOutlet UIButton *southButton;
@property (strong, nonatomic) IBOutlet UIButton *westButton;


@end


