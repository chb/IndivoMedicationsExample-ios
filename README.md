Indivo Medications Sample
=========================

This is a simple sample App to demonstrate basic usage of Indivo's [iOS framework][framework]. The interesting parts are:


## Registering the App with Indivo

To allow the app to run with your instance of Indivo 2.0, add the following file `manifest.json` to the server directory `/registered_apps/user/`:

	{
	  "name" : "Med Sample",
	  "description" : "Sample iOS app for medication management",
	  "author" : "Pascal Pfiffner, pascal.pfiffner@childrens.harvard.edu",
	  "id" : "medsample@apps.indivo.org",
	  "version" : "1.0.0",
	  "smart_version": "0.4",
	
	  "mode" : "ui",	
	  "scope": "record",
	  "has_ui": false,
	  "frameable": false,
	
	  "icon" :  "",
	  "index": "indivo-framework:///did_select_record?record_id={record_id}&carenet_id={carenet_id}"
	}

And, in the same directory, add `credentials.json`:

	{
	  "consumer_key": "medsample@apps.indivo.org",
	  "consumer_secret": "medsample"
	}

**NEVER USE SUCH SIMPLE KEYS AND SECRETS IN PRODUCTION APPS!**

Don't forget to let the server know about the app afterwards:

	$ python manage.py sync_apps

Then, in the Indivo framework project, copy the file `IndivoConfig-default.h` to `IndivoConfig.h` and adjust the values and your server settings accordingly.


## AppDelegate

The app delegate holds a reference to the `IndivoServer` instance `indivo`, which is the base point for all transactions with our Indivo Server. Upon App launch, the app delegate sets up this instance with:

	self.indivo = [IndivoServer serverWithDelegate:self];

This method reads configuration details from `IndivoConfig.h`. See the framework's README on how to configure the framework.

The app delegate is also our `IndivoServerDelegate` and thus needs to implement two delegate methods. In our case the implementation is very simple, but of course you can do whatever you deem useful in them.

	- (UIViewController *)viewControllerToPresentLoginViewController:(IndivoLoginViewController *)loginVC
	{
		return window.rootViewController;
	}
	
	- (void)userDidLogout:(IndivoServer *)fromServer
	{
		[listController unloadData];
	}


## MedListViewController

An instance of this class is the view controller for the medication list. It holds on to the currently selected indivo record, an ivar called `activeRecord` of class `IndivoRecord`, and does four things:


### Have the user select a record ###

	[APP_DELEGATE.indivo selectRecord:^(BOOL userDidCancel, NSString *errorMessage) {
		// record selection completed
	}];

The view controller displays a *connect* button top left, which upon touching calls IndivoServer's `selectRecord:` method. See the actual implementation in the code: if selecting a record was successful (i.e. `userDidCancel` is `NO` and `errorMessage` is `nil` in the callback), the active record's current medication is fetched.


### Fetch the selected record's medications ###

	[activeRecord fetchReportsOfClass:[IndivoMedication class]
	                         callback:^(BOOL success, NSDictionary *__autoreleasing userInfo) {
		// report fetching completed
	}];
	
If this fetch call was successful as well, the record's medications will be available in the `userDict` dictionary supplied to the callback block, the value associated with `INResponseArrayKey`. These will be of the same class as supplied to the fetchRecord call, in our case `IndivoMedication` objects. We assign this array to an ivar array in order to…


### Display a list of medications ####

As any standard UITableViewController, this class is also responsible to feed the table view it is displaying. Nothing special going on here, you can go about your business. Move along, move along.


### Add a medication ####

The demo currently does something you want to do differently in your app: it has the `addMedication:` button which creates a new instance of `IndivoMedication` and after assigning hardcoded values immediately pushes this document to the server. What you want to do is create a new document, display an edit view and have the user manually save the document after he is satisfied with the data. In any case, the code still shows you how to:

- #### Create a (medication) document
	You simply create a new instance of the desired document class
		
		NSError *error = nil;
		IndivoMedication *newMed = [activeRecord addDocumentOfClass:[IndivoMedication class]
		                                                      error:&error];
	
	After the document's properties have been set to reflect the desired medication, it's time to upload it to the server:
	
- #### Push new documents to the server
	To add a document to the selected record, you simply push it:
		
		[newMed push:^(BOOL didCancel, NSString *errorString) {
			if (errorString) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error pushing to server"
				                                                message:errorString
				                                               delegate:nil
				                                      cancelButtonTitle:@"OK"
				                                      otherButtonTitles:nil];
				[alert show];
			}
		}];
	And that's it, you've added a new medication to the record on the server!


[framework]: https://github.com/chb/IndivoFramework-ios


## MedViewController ##

Currently this view controller simply displays some medication details, it should be extended to demonstrate more functionality.
