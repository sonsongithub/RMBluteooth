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
	CBCharacteristic		*_readCharacteristic;
	CBCharacteristic		*_writeCharacteristic;
	CBCharacteristic		*_notifyCharacteristic;
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
	CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc] initWithType:RMBTReadCharacteristicUUID
																					 properties:CBCharacteristicPropertyRead
																						  value:nil
																					permissions:CBAttributePermissionsReadable];
	CBMutableCharacteristic * writeCharacteristic = [[CBMutableCharacteristic alloc] initWithType:RMBTWriteCharacteristicUUID
																					   properties:CBCharacteristicPropertyWrite
																							value:nil
																					  permissions:CBAttributePermissionsWriteable];
	CBMutableCharacteristic * notifyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:RMBTNotifyConnectionCharacteristicUUID
																						properties:CBCharacteristicPropertyNotify
																							 value:nil
																					   permissions:CBAttributePermissionsReadable];
	[serviceToFetchFromIOS setCharacteristics:@[readCharacteristic, writeCharacteristic, notifyCharacteristic]];
	[_peripheralManager addService:serviceToFetchFromIOS];
	
	_readCharacteristic = readCharacteristic;
	_writeCharacteristic = writeCharacteristic;
	_notifyCharacteristic = notifyCharacteristic;
	
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
	_notifyCharacteristic = characteristic;
	DNSLog(@"%ld", (long)manager.state);
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
	DNSLogMethod
	DNSLog(@"%ld", (long)manager.state);
	[self startAdvertise];
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveReadRequest:(CBATTRequest *)request {
	// 更新なし
	[request setValue:[NSData data]];
	[_peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveWriteRequests:(NSArray *)requests{
	DNSLogMethod
	DNSLog(@"%ld", (long)manager.state);
	for(CBATTRequest * request in requests){
		NSData *incommingData = request.value;
		DNSLog(@"data in %ld", (long)incommingData.length);
		
		NSString *string = [[NSString alloc] initWithData:incommingData encoding:NSUTF8StringEncoding];
		DNSLog(@"%@", string);
		
		[self.delegate controller:self didReceiveLog:string];
	
		[manager respondToRequest:request withResult:CBATTErrorSuccess];
	}
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager*)manager{
    DNSLogMethod
}


@end
