/**
 * Card IO
 *
 * Created by Likely Solutions
 * Copyright (c) 2015 Likely Solutions. All rights reserved.
 */

#import "ComLikelysoftCardioModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation ComLikelysoftCardioModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"c0304131-9611-4fff-9f83-f48bc9fa1714";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.likelysoft.cardio";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
    [CardIOUtilities preload];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

- (void)scanCard:(id)args {
    ENSURE_UI_THREAD(scanCard,args);
    
    _callback = [[args objectAtIndex:0] retain];
    
    CardIOPaymentViewController *scanViewController = [[[CardIOPaymentViewController alloc] initWithPaymentDelegate:self] autorelease];
    
    [[TiApp app] showModalController:scanViewController animated:YES];
}

#pragma Card.IO Delegate APIs
- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:@"cancel" forKey:@"success"];
    [self _fireEventToListener:@"completed" withObject:event listener:self._callback thisObject:nil];
    
    // Handle user cancellation here...
    [[[TiApp app] controller] dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:info.cardNumber forKey:@"cardNumber"];
    [event setObject:info.redactedCardNumber forKey:@"redactedCardNumber"];
    [event setObject:[NSString stringWithFormat:@"%lu",(unsigned long)info.expiryMonth] forKey:@"expiryMonth"];
    [event setObject:[NSString stringWithFormat:@"%lu",(unsigned long)info.expiryYear] forKey:@"expiryYear"];
    [event setObject:info.cvv forKey:@"cvv"];
    [event setObject:@"true" forKey:@"success"];
    [self _fireEventToListener:@"completed" withObject:event listener:self._callback thisObject:nil];
    
    [[[TiApp app] controller] dismissViewControllerAnimated:YES completion:nil];
    
}


@synthesize _callback;

@end
