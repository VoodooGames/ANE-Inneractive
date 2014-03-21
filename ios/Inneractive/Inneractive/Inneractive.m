//
//  Inneractive.m
//  Inneractive
//
//  Copyright (c) 2014 Studio Cadet. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import "Inneractive.h"
#import "InneractiveAd.h"

/** The extension context. */
FREContext extCtx = nil;

/** The Inneractive App id set during the extension context initialization. */
NSString *appId = nil;

/** The displayed banner ad. */
InneractiveAd *bannerAd = nil;

/**
 * Macros used to ease the process of declaring functions.
 */
#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }


/**
 * Shortcut for dispatching native events.
 */
void dispatchNativeEvent(NSString *event, NSString *data) {
    FREDispatchStatusEventAsync(extCtx, (uint8_t*) [event UTF8String], (uint8_t*) [data UTF8String]);
}

/**
 * Logs the given message and dispatches the given event.
 */
void logAndDispatch(NSString *message, NSString *event) {
    NSLog(@"%@", message);
    dispatchNativeEvent(event, message);
}

/////////////////////////////////
// INNERACTIVE SHARED INSTANCE //
/////////////////////////////////

@implementation Inneractive

static id sharedInstance = nil;

+ (Inneractive *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}

//////////////////////////////////////////
// InneractiveAdDelegate implementation //
//////////////////////////////////////////

- (void)IaAdReceived {
    NSLog(@"Banner paid ad received");
    dispatchNativeEvent(@"BANNER_DISPLAYED", @"true");
}

- (void)IaDefaultAdReceived {
    NSLog(@"Banner default ad received");
    dispatchNativeEvent(@"BANNER_DISPLAYED", @"false");
}

- (void)IaAdFailed {
    logAndDispatch(@"Banner ad failed", @"BANNER_FAILED");
}

- (void)IaInterstitialAdLoaded
{
    NSLog(@"Interstitial paid ad received");
    dispatchNativeEvent(@"INTERSTITIAL_FETCHED", @"true");
}

- (void)IaDefaultInterstitialAdLoaded {
    NSLog(@"Interstitial default ad received");
    dispatchNativeEvent(@"INTERSTITIAL_FETCHED", @"false");
}

- (void)IaFailedToLoadInterstitialAd
{
    logAndDispatch(@"Interstitial ad fetch failed", @"INTERSTITIAL_FETCH_FAILED");
}

- (void)IaAdClicked {
    logAndDispatch(@"Interstitial clicked", @"INTERSTITIAL_CLICKED");
}

- (void)IaDismissScreen {
    logAndDispatch(@"Interstitial closed.", @"INTERSTITIAL_DISMISSED");
}

// You can implement other methods if you want.

@end

///////////////////
// ANE FUNCTIONS //
///////////////////


DEFINE_ANE_FUNCTION(ia_displayBanner) {
    if (bannerAd != nil) {
        logAndDispatch(@"A banner is already displayed, remove it first.", @"BANNER_FAILED");
        return nil;
    }
    
    uint32_t stringLength;
    const uint8_t *tempString;
    
    // Get alignment
    NSString *alignment = nil;
    
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &tempString) != FRE_OK) {
        logAndDispatch(@"Invalid alignment.", @"BANNER_FAILED");
        return nil;
    }
    
    alignment = [NSString stringWithUTF8String:(char*)tempString];
    
    NSLog(@"Alignment : %@", alignment);

    // Get refresh rate
    int32_t refreshRate = 0;

    if (FREGetObjectAsInt32(argv[1], &refreshRate) != FRE_OK) {
        logAndDispatch(@"Invalid refresh rate.", @"BANNER_FAILED");
        return nil;
    }

    NSLog(@"Refresh rate : %i", refreshRate);

    NSMutableDictionary *optionalParams = [[NSMutableDictionary alloc] init];
    [optionalParams setObject:[NSNumber numberWithInt:Key_Bottom_Center] forKey:[NSNumber numberWithInt:Key_Alignment]];
    
    // Get keywords
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &tempString) == FRE_OK)
        [optionalParams setObject:[NSString stringWithUTF8String:(char*)tempString] forKey:[NSNumber numberWithInt:Key_Keywords]];

    
    // Get age
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &tempString) == FRE_OK)
        [optionalParams setObject:[NSString stringWithUTF8String:(char*)tempString] forKey:[NSNumber numberWithInt:Key_Age]];
        NSLog(@"Age : %s", tempString);


    // Get gender
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &tempString) == FRE_OK)
        [optionalParams setObject:[NSString stringWithUTF8String:(char*)tempString] forKey:[NSNumber numberWithInt:Key_Gender]];

    
    bannerAd = [[InneractiveAd alloc] initWithAppId:appId withType:IaAdType_Banner withReload:refreshRate withParams:optionalParams];
    bannerAd.delegate = [Inneractive sharedInstance];
    bannerAd.clipsToBounds = true;
    
    UIView* rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    
    bannerAd.frame = CGRectMake(0, (rootView.bounds.size.height - bannerAd.frame.size.height), bannerAd.frame.size.width, bannerAd.frame.size.height);
    
    [rootView addSubview:bannerAd];

    return nil;
}

DEFINE_ANE_FUNCTION(ia_removeBanner) {
    if (bannerAd == nil)
        return nil;
    
    [bannerAd removeFromSuperview];
    bannerAd = nil;
    
    return nil;
}

DEFINE_ANE_FUNCTION(ia_fetchInterstitial) {
    if ([InneractiveAd isInterstitialReady]) {
        NSLog(@"An interstitial ad is already ready. Aborting fetch.");
        [[Inneractive sharedInstance] IaInterstitialAdLoaded];
        
        return nil;
    }
    
    uint32_t stringLength;
    const uint8_t *tempString;
    
    NSMutableDictionary *optionalParams = [[NSMutableDictionary alloc] init];
    [optionalParams setObject:[NSNumber numberWithInt:Key_Bottom_Center] forKey:[NSNumber numberWithInt:Key_Alignment]];
    
    // Get keywords
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &tempString) == FRE_OK)
        [optionalParams setObject:[NSString stringWithUTF8String:(char*)tempString] forKey:[NSNumber numberWithInt:Key_Keywords]];
    
    // Get age
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &tempString) == FRE_OK)
        [optionalParams setObject:[NSString stringWithUTF8String:(char*)tempString] forKey:[NSNumber numberWithInt:Key_Age]];
    
    // Get gender
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &tempString) == FRE_OK)
        [optionalParams setObject:[NSString stringWithUTF8String:(char*)tempString] forKey:[NSNumber numberWithInt:Key_Gender]];

    [InneractiveAd loadInterstitialAd:appId withParams:optionalParams withDelegate:[Inneractive sharedInstance]];
    
    return nil;
}

DEFINE_ANE_FUNCTION(ia_showInterstitial) {
    FREObject result = nil;
    
    if (![InneractiveAd isInterstitialReady]) {
        NSLog(@"No interstitial ready, aborting display.");
        
        FRENewObjectFromBool(false, &result);
        return result;
    }
    
    [InneractiveAd showInterstitialAd];
    
    FRENewObjectFromBool(true, &result);
    return result;
}

///////////////////////////////////////////////
// CONTEXT & EXTENSION INITIALIZER/FINALIZER //
///////////////////////////////////////////////

/**
 * Method called by the initializer when initializing the ANE.
 * Registers the links between AS3 method and Obj-C methods.
 */
void InneractiveExtensionContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
    static FRENamedFunction functionMap[] = {
        MAP_FUNCTION(ia_displayBanner, NULL),
        MAP_FUNCTION(ia_removeBanner, NULL),
        MAP_FUNCTION(ia_fetchInterstitial, NULL),
        MAP_FUNCTION(ia_showInterstitial, NULL),
    };
    
	*numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;
    
    extCtx = ctx;
    appId = [NSString stringWithUTF8String:(const char*)ctxType];
}

void InneractiveExtensionContextFinalizer(FREContext ctx) {
    return;
}

/**
 * Method called when initializing the extension context.
 * The name of this method must match the initializer node in the iPhone-ARM platform of the extension.xml file.
 */
void InneractiveExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &InneractiveExtensionContextInitializer;
    *ctxFinalizerToSet = &InneractiveExtensionContextFinalizer;
}