//
//  RMBTCommon.m
//  RMBTController
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "RMBTCommon.h"

NSString * const RMBTServiceUUIDString							= @"990B";
NSString * const RMBTReadCharacteristicUUIDString				= @"2A01";
NSString * const RMBTWriteCharacteristicUUIDString				= @"2A02";
NSString * const RMBTNotifyConnectionCharacteristicUUIDString	= @"2A03";


@implementation CBService (RMBTCommon)

- (void)log {
	NSLog(@"<--");
	NSLog(@"CBService UUID = %@", self.UUID);
	NSLog(@" Peripheral UUID = %@", self.peripheral.identifier);
	NSLog(@" %ld included services", (unsigned long)[self.includedServices count]);
	NSLog(@" %ld included characteristics", (unsigned long)[self.characteristics count]);
	NSLog(@"-->");
}

- (CBCharacteristic*)characteristicOfCharacteristicUUID:(CBUUID*)characteristicUUID {
	for (CBCharacteristic *characteristic in self.characteristics) {
		if (CBUUIDEqual(characteristic.UUID, characteristicUUID))
			return characteristic;
	}
	return nil;
}

@end


@implementation CBPeripheral (RMBTCommon)

- (void)log {
	NSLog(@"<--");
	NSLog(@"CBPeripheral UUID = %@", self.identifier);
	NSLog(@" %ld services", (unsigned long)[self.services count]);
	NSLog(@" %@", self.RSSI);
	NSLog(@" %@", self.name);
	switch (self.state) {
		case CBPeripheralStateConnected:
			NSLog(@"CBPeripheralStateConnected");
			break;
		case CBPeripheralStateConnecting:
			NSLog(@"CBPeripheralStateConnecting");
			break;
		case CBPeripheralStateDisconnected:
			NSLog(@"CBPeripheralStateDisconnected");
			break;
	};
	NSLog(@"-->");
}

- (CBCharacteristic*)characteristicOfCharacteristicUUID:(CBUUID*)characteristicUUID inService:(CBUUID*)serviceUUID {
	for (CBService *service in self.services) {
		if (CBUUIDEqual(service.UUID, serviceUUID)) {
			return [service characteristicOfCharacteristicUUID:characteristicUUID];
		}
	}
	return nil;
}

@end