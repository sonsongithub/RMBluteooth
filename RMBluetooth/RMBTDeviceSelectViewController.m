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

@implementation RMBTDeviceSelectViewController

+ (UINavigationController*)viewController {
	RMBTDeviceSelectViewController *con = [[RMBTDeviceSelectViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
	return nav;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
//	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//	[button setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
//	[button setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
//	[button addTarget:self action:@selector(disconnect:) forControlEvents:UIControlEventTouchUpInside];
//	[self.view.superview addSubview:button];
//	button.frame = self.view.superview.bounds;
}

- (void)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)disconnect:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Select device", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
	
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
