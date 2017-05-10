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
    
    paypalLogo = YES;
    cardIOLogo = NO;
    collectCVV = YES;
    locale = @"en";

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

-(id)paypalLogo {
    return NUMBOOL(paypalLogo);
}

-(void)setPaypalLogo:(id)value {
    NSNumber * numValue = [value retain];
    paypalLogo = [numValue boolValue];
}

-(id)cardIOLogo {
    return NUMBOOL(cardIOLogo);
}

-(void)setCardIOLogo:(id)value {
    NSNumber * numValue = [value retain];
    cardIOLogo = [numValue boolValue];
}

-(void)setCollectCVV:(id)value {
    NSNumber * numValue = [value retain];
    collectCVV = [numValue boolValue];
}

-(id)guideColor {
    return [[[TiColor alloc] initWithColor:guideColor name:@"#fff"] autorelease];
}

-(void)setGuideColor:(id)color {
    if ([color isKindOfClass:[UIColor class]])
    {
        guideColor = color;
    }
    else
    {
        TiColor *ticolor = [TiUtils colorValue:color];
        guideColor = [ticolor _color];
    }
}

-(id)locale {
    return locale;
}

-(void)setLocale:(id)localeValue {
    ENSURE_STRING(localeValue);
    
    locale = [localeValue retain];
}

- (void)scanCard:(id)args {
    ENSURE_UI_THREAD(scanCard,args);
    
    _callback = [[args objectAtIndex:0] retain];
    
    CardIOPaymentViewController *scanViewController = [[[CardIOPaymentViewController alloc] initWithPaymentDelegate:self] autorelease];
    scanViewController.hideCardIOLogo = !paypalLogo;
    scanViewController.useCardIOLogo = cardIOLogo;
    scanViewController.languageOrLocale = locale;
    scanViewController.collectCVV = collectCVV;
    
    if (guideColor) {
        scanViewController.guideColor = guideColor;
    }
    	
    [[TiApp app] showModalController:scanViewController animated:YES];
}

#pragma Card.IO Delegate APIs
- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:@"cancel" forKey:@"success"];
    [self _fireEventToListener:@"completed" withObject:event listener:self._callback thisObject:nil];
    
    [self fireEvent:@"error" withObject:event];
    
    // Handle user cancellation here...
    [[[TiApp app] controller] dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    
    if (collectCVV) {
        NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    }
    else {
        NSLog(@"Received card info. Number: %@, expiry: %02i/%i.", info.redactedCardNumber, info.expiryMonth, info.expiryYear);
    }
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:info.cardNumber forKey:@"cardNumber"];
    [event setObject:info.redactedCardNumber forKey:@"redactedCardNumber"];
    [event setObject:[NSString stringWithFormat:@"%lu",(unsigned long)info.expiryMonth] forKey:@"expiryMonth"];
    [event setObject:[NSString stringWithFormat:@"%lu",(unsigned long)info.expiryYear] forKey:@"expiryYear"];
    
    if (collectCVV) {
        [event setObject:info.cvv forKey:@"cvv"];
    }
    
    [event setObject:@"true" forKey:@"success"];
    [self _fireEventToListener:@"completed" withObject:event listener:self._callback thisObject:nil];
    
    [self fireEvent:@"complete" withObject:event];
    
    [[[TiApp app] controller] dismissViewControllerAnimated:YES completion:nil];
    
}


@synthesize _callback;

@end
