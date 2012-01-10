/*
 MedListViewController.m
 Medications Sample
 
 Created by Pascal Pfiffner on 9/26/11.
 Copyright (c) 2011 Children's Hospital Boston
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "MedListViewController.h"
#import "AppDelegate.h"
#import "IndivoRecord.h"
#import "IndivoMedication.h"
#import "MedViewController.h"


@interface MedListViewController ()

- (void)selectRecord:(id)sender;
- (void)cancelSelection:(id)sender;
- (void)setRecordButtonTitle:(NSString *)aTitle;
- (void)showMedication:(IndivoMedication *)aMedication animated:(BOOL)animated;

@end


@implementation MedListViewController

@synthesize activeRecord, meds;



#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Medications";
	
	// Select Records button
	[self setRecordButtonTitle:nil];
	
    // Allow to add medications
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMedication:)];
	addButton.enabled = (nil != self.activeRecord);
	self.navigationItem.rightBarButtonItem = addButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
}



#pragma mark - Record Handling
/**
 *	Called when the user logged out
 */
- (void)unloadData
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.activeRecord = nil;
	self.meds = nil;
	[self.tableView reloadData];
	[self setRecordButtonTitle:nil];
}

/**
 *	Connecting to the server retrieves the records of your users account
 */
- (void)selectRecord:(id)sender
{
	// create an activity indicator to show that something is happening
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem *activityButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	[activityButton setTarget:self];
	[activityButton setAction:@selector(cancelSelection:)];
	self.navigationItem.leftBarButtonItem = activityButton;
	[activityView startAnimating];
	
	// select record
	[APP_DELEGATE.indivo selectRecord:^(BOOL userDidCancel, NSString *errorMessage) {
		
		// there was an error selecting the record
		if (errorMessage) {
			[self setRecordButtonTitle:[activeRecord label]];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect"
															message:errorMessage
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
		}
		
		// successfully selected record, fetch medications
		else if (!userDidCancel) {
			self.activeRecord = [APP_DELEGATE.indivo activeRecord];
			[self setRecordButtonTitle:[activeRecord label]];
			self.navigationItem.rightBarButtonItem.enabled = (nil != self.activeRecord);
			
			// fetch this record's medications
			[activeRecord fetchReportsOfClass:[IndivoMedication class]
								   withStatus:INDocumentStatusActive
									 callback:^(BOOL success, NSDictionary *__autoreleasing userInfo) {
				
				// error fetching medications
				if (!success) {
					NSString *errorMessage = [[userInfo objectForKey:INErrorKey] localizedDescription];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to get medications"
																	message:errorMessage
																   delegate:nil
														  cancelButtonTitle:@"OK"
														  otherButtonTitles:nil];
					[alert show];
				}
				
				// successfully fetched medications, display
				else if (!userDidCancel) {
					self.meds = [userInfo objectForKey:INResponseArrayKey];
					[self.tableView reloadData];
				}
			}];
		}
		
		// cancelled
		else {
			[self setRecordButtonTitle:[activeRecord label]];
		}
	}];
}

/**
 *	Cancels current connection attempt
 */
- (void)cancelSelection:(id)sender
{
	/// @todo cancel if still in progress
	[self setRecordButtonTitle:nil];
}

/**
 *	Reverts the navigation bar "connect" button
 */
- (void)setRecordButtonTitle:(NSString *)aTitle
{
	NSString *title = ([aTitle length] > 0) ? aTitle : @"Connect";
	UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(selectRecord:)];
	self.navigationItem.leftBarButtonItem = connectButton;
}



#pragma mark - Medication Handling
/**
 *	Called when the user taps a medication row, shows the details for the selected medication
 */
- (void)showMedication:(IndivoMedication *)aMedication animated:(BOOL)animated
{
	if (aMedication) {
		MedViewController *viewController = [MedViewController new];
		viewController.medication = aMedication;
		[self.navigationController pushViewController:viewController animated:animated];
	}
}

/**
 *	Adds a medication to the active record
 */
- (void)addMedication:(id)sender
{
	NSError *error = nil;
	IndivoMedication *newMed = (IndivoMedication *)[activeRecord addDocumentOfClass:[IndivoMedication class] error:&error];
	if (!newMed) {
		DLog(@"Error: %@", [error localizedDescription]);
		// handle error
		return;
	}
	
	newMed.name.text = @"L-Ascorbic Acid";
	newMed.brandName.text = @"Vitamin C";
	newMed.brandName.abbrev = @"vitamin-c";
	[self showMedication:newMed animated:YES];
	[self.tableView reloadData];
	
	// push to the server
	[newMed push:^(BOOL didCancel, NSString *errorString) {
		if (errorString) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error pushing to server"
															message:errorString
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
		}
		else if (!didCancel) {
			self.meds = [meds arrayByAddingObject:newMed];
			[self.tableView reloadData];
		}
	}];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (0 == section) {
		return [meds count];
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	if (0 == indexPath.section && [meds count] > indexPath.row) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		// display the name
		IndivoMedication *med = [meds objectAtIndex:indexPath.row];
		cell.textLabel.text = med.brandName.text;
		return cell;
	}
	return nil;
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 != indexPath.section || indexPath.row >= [meds count]) {
		return;
	}
	
	IndivoMedication *selected = [meds objectAtIndex:indexPath.row];
    [self showMedication:selected animated:YES];
}

@end
