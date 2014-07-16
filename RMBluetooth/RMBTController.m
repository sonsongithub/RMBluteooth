//
//  RMBTController.m
//  RMBTController
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "RMBTController.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
	#import <UIKit/UIKit.h>
#endif

#import "RMBTCommon.h"

@interface RMBTController () <CBPeripheralManagerDelegate> {
	CBPeripheralManager		*_peripheralManager;
	
	CBCharacteristic		*_writeLogCharacteristic;
	CBCharacteristic		*_notifyCommandCharacteristic;
	CBCharacteristic		*_writeROMOAckCharacteristic;
}
@end

static RMBTController *sharedRMBTController = nil;

@implementation RMBTController

#pragma mark - Class method

+ (instancetype)sharedInstance {
	if (sharedRMBTController == nil) {
		sharedRMBTController = [[RMBTController alloc] init];
	}
	return sharedRMBTController;
}

#pragma mark - Override

- (instancetype)init {
    self = [super init];
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - Manage advertising

- (void)startAdvertise {
	CBMutableService *serviceToFetchFromIOS = [[CBMutableService alloc] initWithType:RMBTServiceUUID
																			 primary:YES];
	
	_writeLogCharacteristic = [[CBMutableCharacteristic alloc] initWithType:RMBTWriteLogCharacteristicUUID
																 properties:CBCharacteristicPropertyWrite
																	  value:nil
																permissions:CBAttributePermissionsWriteable];
	_notifyCommandCharacteristic = [[CBMutableCharacteristic alloc] initWithType:RMBTNotifyCommandCharacteristicUUID
																	  properties:CBCharacteristicPropertyNotify
																		   value:nil
																	 permissions:CBAttributePermissionsWriteable];
	_writeROMOAckCharacteristic = [[CBMutableCharacteristic alloc] initWithType:RMBTWriteROMOAckCharacteristicUUID
																	  properties:CBCharacteristicPropertyWrite
																		   value:nil
																	 permissions:CBAttributePermissionsWriteable];

	
	NSArray *characteristics = @[
								 _writeLogCharacteristic,
								 _notifyCommandCharacteristic,
								 _writeROMOAckCharacteristic
								 ];
	
	[serviceToFetchFromIOS setCharacteristics:characteristics];
	[_peripheralManager addService:serviceToFetchFromIOS];
	
	NSArray *serviceUUIDList = @[
								 RMBTServiceUUID
								 ];
#if __MAC_OS_X_VERSION_MIN_REQUIRED
	NSString *name = [[NSHost currentHost] localizedName];
#elif defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
	NSString *name = [UIDevice currentDevice].name;
#endif
	
	NSDictionary *info = @{
						   CBAdvertisementDataServiceUUIDsKey : serviceUUIDList,
						   CBAdvertisementDataLocalNameKey : name
						   };
	
	[_peripheralManager startAdvertising:info];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)manager {
	DNSLogMethod
	if (manager.state == CBPeripheralManagerStatePoweredOn && manager.isAdvertising == NO) {
		[self startAdvertise];
	}
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)manager error:(NSError *)error{
	DNSLogMethod
	DNSLog(@"%@", error);
}

- (void)peripheralManager:(CBPeripheralManager*)manager didAddService:(CBService *)service error:(NSError *)error{
	DNSLogMethod
	DNSLog(@"%@", error);
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
	DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
	DNSLogMethod
	DNSLog(@"%ld", (long)manager.state);
	[self startAdvertise];
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveReadRequest:(CBATTRequest *)request {
	[request setValue:[NSData data]];
	[_peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveWriteRequests:(NSArray *)requests{
	DNSLogMethod
	for(CBATTRequest * request in requests){
		NSData *incommingData = request.value;
		DNSLog(@"data in %ld", (long)incommingData.length);
		
		if (CBUUIDEqual(request.characteristic.UUID, _writeLogCharacteristic.UUID)) {
			NSString *string = [[NSString alloc] initWithData:incommingData encoding:NSUTF8StringEncoding];
			[self.delegate controller:self didReceiveLog:string];
		}
		else if (CBUUIDEqual(request.characteristic.UUID, _notifyCommandCharacteristic.UUID)) {
		}
		else if (CBUUIDEqual(request.characteristic.UUID, _writeROMOAckCharacteristic.UUID)) {
			unsigned char *p = (unsigned char*)[incommingData bytes];
			unsigned char flag = *p;
			DNSLog(@"%ld", flag);
		}

		[manager respondToRequest:request withResult:CBATTErrorSuccess];
	}
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager*)manager{
    DNSLogMethod
}

- (void)sendChar:(char)c {
	NSData *data = [NSData dataWithBytes:&c length:1];
	[_peripheralManager updateValue:data forCharacteristic:(CBMutableCharacteristic*)_notifyCommandCharacteristic onSubscribedCentrals:nil];
}

- (void)hoge {
	[_peripheralManager updateValue:[NSData data] forCharacteristic:(CBMutableCharacteristic*)_notifyCommandCharacteristic onSubscribedCentrals:nil];
}

@end