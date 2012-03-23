/*
 AppDelegate.m
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

#import "AppDelegate.h"
#import "MedListViewController.h"
#import "IndivoServer.h"
#import "IndivoAppDocument.h"


@interface AppDelegate ()

@property (nonatomic, readwrite, strong) IndivoServer *indivo;
@property (nonatomic, strong) MedListViewController *listController;

@end


/**
 *	The sample's application App Delegate.
 *	Here, we setup the indivo server after the App has launched.
 */
@implementation AppDelegate

@synthesize window;
@synthesize indivo, listController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Setup the UI
	self.listController = [[MedListViewController alloc] initWithStyle:UITableViewStylePlain];
	window.rootViewController = [[UINavigationController alloc] initWithRootViewController:listController];
	[window makeKeyAndVisible];
	
    // Setup the server
	self.indivo = [IndivoServer serverWithDelegate:self];
	
	/*/ ** Demo: Fetch application specific documents
	[indivo fetchAppSpecificDocumentsWithCallback:^(BOOL success, NSDictionary *__autoreleasing userInfo) {
		
		// success, pull the individual app documents
		if (success) {
			NSArray *appDocuments = [userInfo objectForKey:INResponseArrayKey];
			if ([appDocuments count] > 0) {
				for (IndivoAppDocument *appDoc in appDocuments) {
					[appDoc pull:^(BOOL userDidCancel, NSString *__autoreleasing errorMessage) {
						if (errorMessage) {
							DLog(@"Error pulling app document: %@", errorMessage);
						}
					}];
				}
			}
			
			// there is none, create one
			else {
				IndivoAppDocument *newAppDoc = [IndivoAppDocument newOnServer:indivo];
				
				NSDictionary *childDict = [NSDictionary dictionaryWithObject:@"a node attribute" forKey:@"foo"];
				INXMLNode *aChild = [INXMLNode nodeWithName:@"child" attributes:childDict];
				[newAppDoc.tree addChild:aChild];
				
				// push
				[newAppDoc push:^(BOOL userDidCancel, NSString *__autoreleasing errorMessage) {
					if (errorMessage) {
						DLog(@"Error pushing new app document: %@", errorMessage);
					}
				}];
			}
		}
		
		// log failure
		else {
			DLog(@"Failed to get app specific documents: %@", [[userInfo objectForKey:INErrorKey] localizedDescription]);
		}
	}];	//	*/
	
    return YES;
}



#pragma mark - Indivo Framework Delegate
- (UIViewController *)viewControllerToPresentLoginViewController:(IndivoLoginViewController *)loginVC
{
	return window.rootViewController;
}

- (void)userDidLogout:(IndivoServer *)fromServer
{
	[listController unloadData];
}


@end
