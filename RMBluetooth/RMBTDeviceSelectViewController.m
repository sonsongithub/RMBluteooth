//
//  RMBTDeviceSelectViewController.m
//  RMBTReceiver
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "RMBTDeviceSelectViewController.h"

#import "RMBTReceiver.h"
#import "RMBTPeripheralInfo.h"

@interface RMBTDeviceSelectViewController() {
	UIButton *_disconnectButton;
}
@end

@implementation RMBTDeviceSelectViewController

+ (UINavigationController*)viewController {
	RMBTDeviceSelectViewController *con = [[RMBTDeviceSelectViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
	return nav;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setDisconnectButtonHidden:![[RMBTReceiver sharedInstance] isConnected]];
}

- (void)setDisconnectButtonHidden:(BOOL)hidden {
	if (hidden) {
		[UIView animateWithDuration:0.3
						 animations:^{
							 _disconnectButton.alpha = 0;
						 }
						 completion:^(BOOL finished) {
							 [_disconnectButton removeFromSuperview];
						 }];
	}
	else {
		_disconnectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_disconnectButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
		[_disconnectButton setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
		[_disconnectButton addTarget:self action:@selector(disconnect:) forControlEvents:UIControlEventTouchUpInside];
		[self.view.superview addSubview:_disconnectButton];
		_disconnectButton.frame = self.view.superview.bounds;
		_disconnectButton.alpha = 0;
		[UIView animateWithDuration:0.3
						 animations:^{
							 _disconnectButton.alpha = 1;
						 }
						 completion:^(BOOL finished) {
						 }];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)disconnect:(id)sender {
	[[RMBTReceiver sharedInstance] disconnect];
}

- (void)did:(NSNotification*)notification {
	DNSLogMethod
	[self.tableView reloadData];
	[self setDisconnectButtonHidden:![[RMBTReceiver sharedInstance] isConnected]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Select device", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(did:)
												 name:RMBTControllerDidChangePeripheralManagerStatus
											   object:nil];
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[RMBTReceiver sharedInstance] peripherals] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	RMBTPeripheralInfo *p = [[[RMBTReceiver sharedInstance] peripherals] objectAtIndex:indexPath.row];
	cell.textLabel.text = p.advertisementData[@"kCBAdvDataLocalName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RMBTPeripheralInfo *p = [[[RMBTReceiver sharedInstance] peripherals] objectAtIndex:indexPath.row];
	[[RMBTReceiver sharedInstance] connectPeripheral:p];
}

@end
