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

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)open:(id)sender {
	[self presentViewController:[RMBTDeviceSelectViewController viewController] animated:YES completion:nil];
}

- (IBAction)send:(id)sender {
	[[RMBTReceiver sharedInstance] sendString:@"test, this is test"];
}

@end
