//
//  RMBTPeripheralInfo.m
//  RMBTReceiver
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "RMBTPeripheralInfo.h"

@implementation RMBTPeripheralInfo

- (NSString*)name {
	NSString *name_A = self.advertisementData[@"kCBAdvDataLocalName"];
	if ([name_A length])
		return name_A;
	return _peripheral.name;
}

@end
