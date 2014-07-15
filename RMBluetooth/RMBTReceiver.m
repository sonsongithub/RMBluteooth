//
//  RMBTReceiver.m
//  RMBTReceiver
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "RMBTReceiver.h"

#import "RMBTCommon.h"
#import "RMBTPeripheralInfo.h"

NSString * const RMBTControllerDidChangePeripheralManagerStatus = @"RMBTControllerDidChangePeripheralManagerStatus";

@interface RMBTReceiver() <CBCentralManagerDelegate,CBPeripheralDelegate> {
	CBCentralManager	*_centralManager;
	CBService			*_service;
	RMBTPeripheralInfo	*_connectedPeripheral;
	
	CBCharacteristic	*_readCharacteristic;
	CBCharacteristic	*_writeCharacteristic;
	CBCharacteristic	*_notifyCharacteristic;
	
	CBCharacteristic	*_sendLogCharacteristic;
	CBCharacteristic	*_receiveCommandCharacteristic;
	
	BOOL				_isScanning;
	NSMutableArray		*_peripherals;
}
@end

@implementation RMBTReceiver

static RMBTReceiver *sharedRMBTReceiver = nil;

#pragma mark - Class method

+ (instancetype)sharedInstance {
	if (sharedRMBTReceiver == nil) {
		sharedRMBTReceiver = [[RMBTReceiver alloc] init];
	}
	return sharedRMBTReceiver;
}

#pragma mark - Send data

- (void)sendLog:(NSString*)string {
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	if (_connectedPeripheral && _sendLogCharacteristic) {
		[_connectedPeripheral.peripheral writeValue:data forCharacteristic:_sendLogCharacteristic type:CBCharacteristicWriteWithResponse];
	}
}

#pragma mark - Manage peripherals

- (BOOL)isAlreadyFoundPeripheral:(CBPeripheral*)peripheral {
	for (RMBTPeripheralInfo *aPeripheral in _peripherals) {
		if ([peripheral.identifier isEqual:aPeripheral.peripheral.identifier]) {
			return YES;
		}
	}
	return NO;
}

#pragma mark - Connection

- (BOOL)isConnected {
	return (_connectedPeripheral.peripheral.state == CBPeripheralStateConnected);
}

- (void)disconnect {
	if (_connectedPeripheral) {
		[_centralManager cancelPeripheralConnection:_connectedPeripheral.peripheral];
	}
}

- (void)connectPeripheral:(RMBTPeripheralInfo*)peripheralInfo {
	[_centralManager connectPeripheral:peripheralInfo.peripheral options:nil];
	_connectedPeripheral = peripheralInfo;
	[self stopScan];
	[_peripherals removeObject:peripheralInfo];
}

- (void)startScan {
	_isScanning = YES;
	NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @(NO)};
#if 0
	// Following code does not work properly.
	// central manager filters all UUID.
	NSArray *UUIDsFilter = @[RMBTServiceUUIDString];
	[_centralManager scanForPeripheralsWithServices:UUIDsFilter options:options];
#else
	[_centralManager scanForPeripheralsWithServices:nil options:options];
#endif
	NSArray *connectedPeripherals = [_centralManager retrieveConnectedPeripheralsWithServices:@[RMBTServiceUUID]];
	for (CBPeripheral *peripheral in connectedPeripherals) {
		RMBTPeripheralInfo *p = [[RMBTPeripheralInfo alloc] init];
		p.peripheral = peripheral;
		[_peripherals addObject:p];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:RMBTControllerDidChangePeripheralManagerStatus object:nil userInfo:nil];
}

- (void)stopScan {
	_isScanning = NO;
	[_centralManager stopScan];
}

#pragma mark - Override

- (instancetype)init {
    self = [super init];
    if (self) {
		_peripherals = [NSMutableArray array];
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)manager {
	DNSLogMethod
	if (_centralManager.state == CBCentralManagerStatePoweredOn && _isScanning == NO) {
		[self startScan];
	}
}

- (void)centralManager:(CBCentralManager*)manager didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData	RSSI:(NSNumber *)RSSI {
	DNSLogMethod
	
	
	NSArray *kCBAdvDataServiceUUIDs = advertisementData[@"kCBAdvDataServiceUUIDs"];
	
	if ([kCBAdvDataServiceUUIDs count] > 0) {
		CBUUID *uuid = kCBAdvDataServiceUUIDs[0];
		DNSLog(@"%@", uuid);
	}
	
	BOOL isAlreadyAdded = [self isAlreadyFoundPeripheral:aPeripheral];
	
	[aPeripheral log];
	
	
	if (isAlreadyAdded) {
	}
	else {
		RMBTPeripheralInfo *p = [[RMBTPeripheralInfo alloc] init];
		p.peripheral = aPeripheral;
		p.advertisementData = advertisementData;
		[_peripherals addObject:p];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:RMBTControllerDidChangePeripheralManagerStatus object:nil userInfo:nil];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    DNSLogMethod
	
	if([peripherals count]){
		CBPeripheral *peripheral = [peripherals objectAtIndex:0];
		[_centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
	}
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    DNSLogMethod
	[_connectedPeripheral.peripheral setDelegate:self];
	[_connectedPeripheral.peripheral discoverServices:nil];
	[self stopScan];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMBTControllerDidChangePeripheralManagerStatus object:nil userInfo:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    DNSLogMethod
	if (error) {
		DNSLog(@"Error=>%@", error);
	}
	_connectedPeripheral = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:RMBTControllerDidChangePeripheralManagerStatus object:nil userInfo:nil];
	[self startScan];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
	DNSLogMethod
	_connectedPeripheral = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:RMBTControllerDidChangePeripheralManagerStatus object:nil userInfo:nil];
	[self startScan];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	DNSLogMethod
	if (error) {
		DNSLog(@"Error=>%@", error);
		return;
	}
	
	if ((characteristic.properties & CBCharacteristicPropertyNotify) && CBUUIDEqual(characteristic.UUID, RMBTSendCommandCharacteristicUUID)){
		NSData *incommingData = characteristic.value;
		//		DNSLog(@"notify data in %ld", incommingData.length);
		NSString *str = [[NSString alloc] initWithData:incommingData encoding:NSUTF8StringEncoding];
		NSLog(@"%@", str);
	}
	else if (characteristic.properties & CBCharacteristicPropertyRead) {
		//NSData *incommingData = characteristic.value;
	}
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
	DNSLogMethod
	if (error) {
		DNSLog(@"Error=%@", error);
		[_centralManager cancelPeripheralConnection:aPeripheral];
	}
	else {
		for (CBService *aService in aPeripheral.services) {
			DNSLog(@"%@", aService);
			DNSLog(@"<<<<<<<<<<%@", aService.UUID.data);
			CBUUID *cbuuid = [CBUUID UUIDWithString:@"990B"];
			if (CBUUIDEqual(aService.UUID, cbuuid)) {
				[aPeripheral discoverCharacteristics:nil forService:aService];
			}
		}
	}
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	DNSLogMethod
	if (error) {
		DNSLog(@"Error=%@", error);
		[_centralManager cancelPeripheralConnection:aPeripheral];
	}
	else {
		DNSLog(@"----------->%@", service.UUID.data);
		DNSLog(@"=======%@", service.characteristics);
		for (CBCharacteristic *characteristic in service.characteristics) {
			DNSLog(@"=>%@", characteristic.UUID);
		}
		if ([service.characteristics count] == 2) {
			_service = service;
			_sendLogCharacteristic = [service characteristicOfCharacteristicUUID:RMBTReceiveLogCharacteristicUUID];
			_receiveCommandCharacteristic = [service characteristicOfCharacteristicUUID:RMBTSendCommandCharacteristicUUID];
			[aPeripheral setNotifyValue:YES forCharacteristic:_receiveCommandCharacteristic];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
	DNSLogMethod
	if (error) {
		DNSLog(@"Error=%@", error);
	}
}

@end
