//
//  ViewController.m
//  RMBTReceiverSample
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "ViewController.h"
#import "RMBTDeviceSelectViewController.h"
#import "RMBTReceiver.h"
#import <RMCore/RMCore.h>

@interface ViewController () <RMCoreDelegate, RMBTReceiverDelegate>
@property (nonatomic, strong) RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot;
@end

@implementation ViewController

- (void)receiver:(RMBTReceiver *)receiver didReceiveCommand:(char)c {
	switch (c) {
		case 'f':
			[self.robot driveForwardWithSpeed:0.5];
			break;
		case 'b':
			[self.robot driveBackwardWithSpeed:0.5];
			break;
		case 'r':
			[self.robot turnByAngle:-20 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE completion:nil];
			break;
		case 'l':
			[self.robot turnByAngle:20 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE completion:nil];
			break;
		case 's':
			[self.robot stopAllMotion];
			break;
		case 'p':
			[self.robot tiltByAngle:5 completion:nil];
			break;
		case 'm':
			[self.robot tiltByAngle:-5 completion:nil];
			break;
		default:
			break;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[RMCore setDelegate:self];
	[RMBTReceiver sharedInstance].delegate = self;
}

- (IBAction)open:(id)sender {
	[self presentViewController:[RMBTDeviceSelectViewController viewController] animated:YES completion:nil];
}

- (IBAction)send:(id)sender {
	[[RMBTReceiver sharedInstance] sendLog:@"test, this is test"];
}

- (IBAction)notify:(id)sender {
	[[RMBTReceiver sharedInstance] notify];
}

- (void)robotDidConnect:(RMCoreRobot *)robot {
    // Currently the only kind of robot is Romo3, so this is just future-proofing
    if (robot.isDrivable && robot.isHeadTiltable && robot.isLEDEquipped) {
        self.robot = (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *) robot;
		[[RMBTReceiver sharedInstance] sendLog:@"ROMO is connected."];
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot {
    if (robot == self.robot) {
        self.robot = nil;
		[[RMBTReceiver sharedInstance] sendLog:@"ROMO is disconnected."];
    }
}

@end
