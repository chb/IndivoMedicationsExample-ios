/*
 AppDelegate.h
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

#import <UIKit/UIKit.h>
#import "IndivoServer.h"
#import "Indivo.h"

@class IndivoRecord;
@class IndivoMedication;


@interface AppDelegate : UIResponder <UIApplicationDelegate, IndivoServerDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;					///< A reference to the main window
@property (nonatomic, readonly, strong) IndivoServer *indivo;				///< The reference to our Indivo Server


@end
