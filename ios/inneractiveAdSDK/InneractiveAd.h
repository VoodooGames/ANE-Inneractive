//
//  InneractiveAd.h
//	InneractiveAdSDK
//
//  Created by Inneractive LTD.
//  Copyright 2011 Inneractive LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 * IaAdType enumeration
 *
 * IaAdType_Banner		- Banner only ad
 * IaAdType_Text		- Text only ad
 * IaAdType_Interstitial- Interstitial ad
 * IaAdType_Rectangle	- Rectangular ad
 */
typedef enum {
	IaAdType_Banner = 1,
	IaAdType_Text,
	IaAdType_Interstitial,
    IaAdType_Rectangle
} IaAdType;

/*
 * IaOptionalParams
 *
 * Key_Age				- User's age
 * Key_Gender			- User's gender (allowed values: M, m, F, f, Male, Female)
 * Key_Gps_Coordinates	- GPS ISO code location data in latitude,longitude format. For example: 53.542132,-2.239856 (w/o spaces)
 * Key_Keywords			- Keywords relevant to this user's specific session (comma separated)
 * Key_Location			- Comma separted list of country,state/province,city. For example: US,NY,NY (w/o spaces)
 * Key_Alignment        - Alignment of ad inside the container
 */
typedef enum {
	Key_Age = 1,
	Key_Gender,
	Key_Gps_Coordinates,
	Key_Keywords,
	Key_Location,
    Key_RequiredAdWidth,
    Key_RequiredAdHeight,
    Key_OptionalAdWidth,
    Key_OptionalAdHeight,
    Key_Alignment
} IaOptionalParams;

/*
 * IaAlignmentParams
 *
 * Key_Top_Left				- Align the ad to top left in the container
 * Key_Top_Center			- Align the ad to top center in the container
 * Key_Top_Right            - Align the ad to top right in the container
 * Key_Bottom_Left			- Align the ad to bottom left in the container
 * Key_Bottom_Center		- Align the ad to bottom center in the container
 * Key_Bottom_Right         - Align the ad to bottom right in the container
 * Key_Center_Left          - Align the ad to center left in the container
 * Key_Center               - Align the ad to center in the container
 * Key_Center_Right         - Align the ad to center right in the container
 */
typedef enum {
	Key_Top_Left = 1,
	Key_Top_Center,
	Key_Top_Right,
	Key_Bottom_Left,
	Key_Bottom_Center,
    Key_Bottom_Right,
    Key_Center_Left,
    Key_Center,
    Key_Center_Right
} IaAlignmentParams;


@protocol InneractiveAdDelegate;

@interface InneractiveAd : UIView {
    id <InneractiveAdDelegate> delegate;
}

@property (nonatomic, retain) id <InneractiveAdDelegate> delegate;

/*
 * Initialize InneractiveAd view
 *
 * (NSString*)appId		Application ID - provided by inneractive at the application registration
 * (IaAdType)adType     Ad type - can be banner only, text only. Interstitial ad support is deprecated.
                        The new loadInterstitialAd and showInterstitialAd methods should be used instead for Interstitial Ads.
 * (int)reloadTime		Reload time - the ad refresh time (not relevant for interstitial ad)
 */
- (id)initWithAppId:(NSString*)appId withType:(IaAdType)adType withReload:(int)reloadTime;

/*
 * Initialize InneractiveAd view
 *
 * (NSString*)appId		Application ID - provided by inneractive at the application registration
 * (IaAdType)adType     Ad type - can be banner only, text only. Interstitial ad support is deprecated.
                        The new loadInterstitialAd and showInterstitialAd methods should be used instead for Interstitial Ads.
 * (int)reloadTime		Reload time - the ad refresh time (not relevant for interstitialn ad)
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 */
- (id)initWithAppId:(NSString*)appId withType:(IaAdType)adType withReload:(int)reloadTime withParams:(NSMutableDictionary*)optionalParams;

/*
 * DisplayAd function displays an ad
 *
 * (NSString*)appId		Application ID - provided by inneractive at the application registration
 * (IaAdType)adType     Ad type - can be banner only, text only. Interstitial ad support is deprecated.
                        The new loadInterstitialAd and showInterstitialAd methods should be used instead for Interstitial Ads.
 * (UIView*)root		Root view - the view in which the ad will be displayed
 * (int)reloadTime		Reload time - the ad refresh time (not relevant for interstitial ad)
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 *  - root is null
 */
+ (BOOL)DisplayAd:(NSString*)appId withType:(IaAdType)adType withRoot:(UIView*)root withReload:(int)reloadTime;

/*
 * DisplayAd function displays an ad
 *
 * (NSString*)appId							Application ID - provided by inneractive at the application registration
 * (IaAdType)adType                         Ad type - can be banner only, text only. Interstitial ad support is deprecated. 
                                            The new loadInterstitialAd and showInterstitialAd methods should be used instead for Interstitial Ads.
 * (UIView*)root							Root view - the view in which the ad will be displayed
 * (int)reloadTime							Reload time - the ad refresh time (not relevant for interstitial ad)
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 *  - root is null
 */
+ (BOOL)DisplayAd:(NSString*)appId withType:(IaAdType)adType withRoot:(UIView*)root withReload:(int)reloadTime withParams:(NSMutableDictionary*)optionalParams;

/*
 * DisplayAd function displays an ad
 *
 * (NSString*)appId							Application ID - provided by inneractive at the application registration
 * (IaAdType)adType                         Ad type - can be banner only, text only. Interstitial ad support is deprecated.
                                            The new loadInterstitialAd and showInterstitialAd methods should be used instead for Interstitial Ads.
 * (UIView*)root							Root view - the view in which the ad will be displayed
 * (int)reloadTime							Reload time - the ad refresh time (not relevant for interstitial ad)
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 * (id<InneractiveAdDelegate>)delegateObj	InneractiveAd delegate
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 *  - root is null
 */
+ (BOOL)DisplayAd:(NSString*)appId withType:(IaAdType)adType withRoot:(UIView*)root withReload:(int)reloadTime withParams:(NSMutableDictionary*)optionalParams withDelegate:(id<InneractiveAdDelegate>)delegateObj;

/*
 * loadInterstitialAd function pre-loads an interstitial ad
 *
 * (NSString*)appId							Application ID - provided by inneractive at the application registration
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 * (id<InneractiveAdDelegate>)delegateObj	InneractiveAd delegate
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 */
+ (BOOL)loadInterstitialAd:(NSString*)appId withParams:(NSMutableDictionary*)optionalParams withDelegate:(id<InneractiveAdDelegate>)delegateObj;

/*
 * showInterstitialAd function displays the last pre-loaded interstitial ad on a full screen view.
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No ad has been pre-loaded prior to showing the interstitial.
 *  - An ad has already been shown once. (new pre-loading is needed)
 */
+ (BOOL)showInterstitialAd;

/*
 * isInterstitialReady function returns the state of the interstitial ad - if it is ready to be shown.
 *
 * Returns YES if the ad is read, or NO if the ad hasn't been downloaded from the server or it's resources (images etc.) have not been downloaded yet.
 */
+ (BOOL)isInterstitialReady;

@end

@protocol InneractiveAdDelegate <NSObject>

@optional
    - (void)IaAdReceived;
    - (void)IaDefaultAdReceived;
    - (void)IaAdFailed;
    - (void)IaAdClicked;
    - (void)IaAdWillShow;
    - (void)IaAdDidShow;
    - (void)IaAdWillHide;
    - (void)IaAdDidHide;
    - (void)IaAdWillClose;
    - (void)IaAdDidClose;
    - (void)IaAdWillResize;
    - (void)IaAdDidResize;
    - (void)IaAdWillExpand;
    - (void)IaAdDidExpand;
    - (void)IaAppShouldSuspend;
    - (void)IaAppShouldResume;
    - (void)IaDismissScreen;

// New Delegate Events for Interstitial Ads.
// -=======================================-

    - (void)IaInterstitialAdLoaded;
    - (void)IaDefaultInterstitialAdLoaded;
    - (void)IaFailedToLoadInterstitialAd;

@end
