/*
 MedViewController.m
 Medications Sample
 
 Created by Pascal Pfiffner on 9/7/11.
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

#import "MedViewController.h"
#import "IndivoDocuments.h"

@interface MedViewController ()

- (void)configureView;

@end


@implementation MedViewController

@synthesize medication;
@synthesize nameLabel, codeLabel;


- (id)init
{
	return [self initWithNibName:@"MedView" bundle:nil];
}



#pragma mark - Managing the detail item
- (void)setMedication:(IndivoMedication *)newMedication
{
    if (newMedication != medication) {
        medication = newMedication;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
	if (self.medication) {
		self.nameLabel.text = medication.drugName.title;
	    self.codeLabel.text = [NSString stringWithFormat:@"RxNorm: %@", ([medication.drugName.identifier length] > 0) ? medication.drugName.identifier : @"unknown"];
	}
}



#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
	self.nameLabel = nil;
	self.codeLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


@end
