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

@interface ViewController () <RMCoreDelegate>
@property (nonatomic, strong) RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *robot;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[RMCore setDelegate:self];
}

- (IBAction)open:(id)sender {
	[self presentViewController:[RMBTDeviceSelectViewController viewController] animated:YES completion:nil];
}

- (IBAction)send:(id)sender {
	[[RMBTReceiver sharedInstance] sendLog:@"test, this is test"];
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
