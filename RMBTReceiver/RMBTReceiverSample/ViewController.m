//
//  ViewController.m
//  RMBTReceiverSample
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "ViewController.h"
#import "RMBTDeviceSelectViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)open:(id)sender {
	RMBTDeviceSelectViewController *con = [[RMBTDeviceSelectViewController alloc] init];
	[self presentViewController:con animated:YES completion:nil];
}

@end
