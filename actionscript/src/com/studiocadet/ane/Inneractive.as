package com.studiocadet.ane {
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	import flash.sampler.getLexicalScopes;
	import flash.system.Capabilities;
	
	/**
	 * A singleton allowing to use native Inneractive ads on Android and iOS.
	 * You should first check if the extension is supported, then initialize it.
	 */
	public class Inneractive {
		
		// PUBLIC CONSTANTS :
		public static const DEVICE_TYPE_ANDROID:String = "Android";
		public static const DEVICE_TYPE_ANDROID_TABLET:String = "AndroidTablet";
		public static const DEVICE_TYPE_IPAD:String = "iPad";
		public static const DEVICE_TYPE_IPHONE:String = "iPhone";
		
		public static const ALIGN_BOTTOM_CENTER:String = "BOTTOM_CENTER";
		public static const ALIGN_BOTTOM_LEFT:String = "BOTTOM_LEFT";
		public static const ALIGN_BOTTOM_RIGHT:String = "BOTTOM_RIGHT";
		public static const ALIGN_CENTER:String = "CENTER";
		public static const ALIGN_CENTER_LEFT:String = "CENTER_LEFT";
		public static const ALIGN_CENTER_RIGHT:String = "CENTER_RIGHT";
		public static const ALIGN_TOP_CENTER:String = "TOP_CENTER";
		public static const ALIGN_TOP_LEFT:String = "TOP_LEFT";
		public static const ALIGN_TOP_RIGHT:String = "TOP_RIGHT";
		
		public static const GENDER_F:String = "F";
		public static const GENDER_M:String = "M";
		
		// PRIVATE CONSTANTS :
		private static const EXTENSION_ID:String = "com.studiocadet.Inneractive";
		
		private static const SIZE_ANDROID:Point = new Point(320, 50);
		private static const SIZE_ANDROID_TABLET:Point = new Point(768, 90);
		private static const SIZE_IPAD:Point = new Point(768, 90);
		private static const SIZE_IPHONE:Point = new Point(320, 50);
		
		private static const ALIGNMENTS:Vector.<String> = new <String>[
				ALIGN_BOTTOM_CENTER, ALIGN_BOTTOM_LEFT, ALIGN_BOTTOM_RIGHT,
				ALIGN_CENTER, ALIGN_CENTER_LEFT, ALIGN_CENTER_RIGHT,
				ALIGN_TOP_CENTER, ALIGN_TOP_LEFT, ALIGN_TOP_RIGHT
			];
		
		// INTERNAL EVENTS :
		private static const EVENT_LOG:String = "LOG";
		private static const EVENT_BANNER_DISPLAYED:String = "BANNER_DISPLAYED";
		private static const EVENT_BANNER_FAILED:String = "BANNER_FAILED";
		private static const EVENT_INTERSTITIAL_FETCHED:String = "INTERSTITIAL_FETCHED";
		private static const EVENT_INTERSTITIAL_FETCH_FAILED:String = "INTERSTITIAL_FETCH_FAILED";
		private static const EVENT_INTERSTITIAL_CLICKED:String = "INTERSTITIAL_CLICKED";
		private static const EVENT_INTERSTITIAL_DISMISSED:String = "INTERSTITIAL_DISMISSED";
		
		
		///////////////
		// SINGLETON //
		///////////////
		
		/** The logging function you want to use. Defaults to trace. */
		public static var logger:Function = trace;
		/** The prefix appended to every log message. Defaults to "[Inneractive]". */
		public static var logPrefix:String = "[Inneractive]";
		
		private static var _isSupported:Boolean;
		private static var _isSupportedInitialized:Boolean;
		/**
		 * Returns true if the extension is supported on the current platform.
		 */
		public static function isSupported():Boolean {
			if(!_isSupportedInitialized) {
				_isSupported = Capabilities.manufacturer.toLowerCase().indexOf("ios") > -1 || Capabilities.manufacturer.toLowerCase().indexOf("and") > -1;
				_isSupportedInitialized = true;
			}
			return _isSupported;
		}
		
		
		/** The extension context. */
		private static var context:ExtensionContext;
		/** The device type. */
		private static var deviceType:String;
		/** The banner size. */
		private static var bannerSize:Point;
		
		
		/**
		 * Initializes the extension with the given shortened app ID and the given device type.
		 * 
		 * @param deviceType		One of the DEVICE_* constants, or leave it to null to auto-detect it.
		 */
		public static function init(deviceType:String= null):void {
			if(!isSupported()) return;
			
			if(context)
				throw new Error("Inneractive should only be initialized once !");
			
			var minScreenSize:int = Math.min(Capabilities.screenResolutionX, Capabilities.screenResolutionY);
			
			if(deviceType == null) {
				if(Capabilities.os.indexOf("iPad") > -1)
					deviceType = DEVICE_TYPE_IPAD;
				else if(Capabilities.os.indexOf("iPhone") > -1)
					deviceType = DEVICE_TYPE_IPHONE;
				else 
					deviceType = minScreenSize <= 768 ? DEVICE_TYPE_ANDROID : DEVICE_TYPE_ANDROID_TABLET;
				log("Detected device type : " + deviceType);
			}
			
			// Iniitialize AS part :
			Inneractive.deviceType = deviceType;
			
			if(deviceType == DEVICE_TYPE_ANDROID) 
				bannerSize = new Point(minScreenSize, minScreenSize / SIZE_ANDROID.x * SIZE_ANDROID.y);
			else if(deviceType == DEVICE_TYPE_ANDROID_TABLET)
				bannerSize = new Point(minScreenSize, minScreenSize / SIZE_ANDROID_TABLET.x * SIZE_ANDROID_TABLET.y);
			else if(deviceType == DEVICE_TYPE_IPAD)
				bannerSize = new Point(minScreenSize, minScreenSize / SIZE_IPAD.x * SIZE_IPAD.y);
			else  
				bannerSize = new Point(minScreenSize, minScreenSize / SIZE_IPHONE.x * SIZE_IPHONE.y);
			
			// Initialize the native part :
			log("Initializing Inneractive extension (device type : " + deviceType + ") ...");
			context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if(context == null) 
				throw new Error("Inneractive is not supported !");
			
			context.addEventListener(StatusEvent.STATUS, bubbleNativeLog, false, 0, true);
		}
		
		
		/////////////
		// BANNERS //
		/////////////
		
		/**
		 * Displays a banner with the given alignment and refresh rate.
		 * 
		 * @param shortenedAppID	The appID to use, without the "_AutoDeviceType" part added by Inneractive
		 * @param alignment			One of the ALIGN_* constants
		 * @param refreshRate		The number of seconds between ad refreshes (min:15, max:300)
		 * @param onSuccess			Called when the banner is displayed. Signature : function(isPaidAd:Boolean):void
		 * @param onFailure			Called when displaying the banner fails for any reason. Signature : function():void
		 * @param keywords			Relevant keywords for ad targeting. For example: cars,music,sports (comma separated, w/o spaces)
		 * @param age				The user's age (between 1 and 120). Leave to -1 to ignore this parameter
		 * @param gender			The user's gender. One of the GENDER_* constants
		 */
		public static function displayBanner(shortenedAppID:String, alignment:String, refreshRate:uint, onSuccess:Function, onFailure:Function, 
											 keywords:String = null, age:int = -1, gender:String = null):void 
		{
			if(!isSupported()) return;
			
			// Check parameters :
			if(ALIGNMENTS.indexOf(alignment) == -1) 
				throw new Error("Invalid alignment : " + alignment);
			if(refreshRate < 15 || refreshRate > 300)
				throw new Error("Invalid refresh rate : " + refreshRate + " (min:15, max:300)");
			if(age == 0 || age > 120)
				throw new Error("Invalid age : " + age + " (min:1, max:120, ignore:<0)");
			if(gender && gender != GENDER_F && gender != GENDER_M)
				throw new Error("Invalid gender : " + gender + ". Use one of the GENDER_* constants.");
			
			const appID:String = shortenedAppID + "_" + deviceType;
			
			// Prepare callbacks :
			context.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			context.call("ia_displayBanner", appID, alignment, refreshRate, keywords, age, gender);
			log("Displaying banner for " + appID + " (align:" + alignment + ", refreshRate:" + refreshRate + "s)");
			
			// Banner display callbacks :
			function onStatus(ev:StatusEvent):void {
				if(ev.code == EVENT_BANNER_DISPLAYED) {
					log("Banner displayed for " + appID + " (is paid ? " + ev.level + ")");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onSuccess != null)
						onSuccess(Boolean(ev.level));
				}
				else if(ev.code == EVENT_BANNER_FAILED) {
					log("Banner failed to display for " + appID + " : " + ev.level);
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onFailure != null)
						onFailure();
				}
			}
		}
		
		/**
		 * Returns the banner's size (x = width, y = height). This method will work as long as the extension has been initialized.
		 */
		public static function getBannerSize():Point {
			if(!isSupported()) return new Point();
			
			return bannerSize;
		}
		
		/**
		 * Removes the currently displayed banner.
		 */
		public static function removeBanner():void {
			if(!isSupported()) return;
			
			context.call("ia_removeBanner");
			log("Banner removed.");
		}
		
		
		//////////////////
		// INTERSTITIAL //
		//////////////////
		
		/**
		 * Fetches an interstitial ad with the given parameters.
		 * 
		 * @param shortenedAppID	The appID to fetch an interstitial for, without the "_AutoDeviceType" part added by Inneractive
		 * @param onFetched			Called when the ad is successfully fetched. Signature : function(isPaidAd:Boolean):void
		 * @param onFailure			Called when the ad fails to be fetched. Signature : function(errorMessage:String):void
		 * @param keywords			Relevant keywords for ad targeting. For example: cars,music,sports (comma separated, w/o spaces)
		 * @param age				The user's age (between 1 and 120). Leave to -1 to ignore this parameter
		 * @param gender			The user's gender. One of the GENDER_* constants
		 */
		public static function fetchInterstitial(shortenedAppID:String, onFetched:Function, onFailure:Function, 
												 keywords:String = null, age:int = -1, gender:String = null):void 
		{
			if(!isSupported()) return;
			
			if(age == 0 || age > 120)
				throw new Error("Invalid age : " + age + " (min:1, max:120, ignore:<0)");
			if(gender && gender != GENDER_F && gender != GENDER_M)
				throw new Error("Invalid gender : " + gender + ". Use one of the GENDER_* constants.");
			
			const appID:String = shortenedAppID + "_" + deviceType;
			
			context.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			context.call("ia_fetchInterstitial", appID, keywords, age, gender);
			log("Fetching an interstitial for " + appID + " ...");
			
			function onStatus(ev:StatusEvent):void {
				if(ev.code == EVENT_INTERSTITIAL_FETCHED) {
					log("Interstitial for " + appID + " fetched succcessfully.");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onFetched != null)
						onFetched(Boolean(ev.level));
				}
				else if(ev.code == EVENT_INTERSTITIAL_FETCH_FAILED) {
					log("Interstitial for " + appID + " fetch failed.");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onFailure != null)
						onFailure();
				}
			}
		}
		
		/**
		 * Displays the previously fetched interstitial.
		 * 
		 * @param onDismiss	Called when the user closes the ad. Signature : function():void
		 * @param onClick	Called when the user clicks on the ad. Signature : function():void
		 */
		public static function showInterstitial(onDismiss:Function, onClick:Function):Boolean {
			if(!isSupported()) return false;
			
			log("Showing the fetched interstitial.");
			context.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			var interstitialDisplayed:Boolean = context.call("ia_showInterstitial");
			if(interstitialDisplayed)
				log("Interstitial displayed successfully.");
			else
				log("Interstitial failed to display");
			
			function onStatus(ev:StatusEvent):void {
				if(ev.code == EVENT_INTERSTITIAL_CLICKED) {
					log("Interstitial clicked.");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onClick != null)
						onClick();
				}
				else if(ev.code == EVENT_INTERSTITIAL_DISMISSED) {
					log("Interstitial dismissed.");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onDismiss != null)
						onDismiss();
				}
			}
			
			return interstitialDisplayed;
		}
		
		
		/////////////
		// LOGGING //
		/////////////
		
		/**
		 * Outputs the given message(s) using the provided logger function, or using trace.
		 */
		private static function log(message:String, ... additionnalMessages):void {
			if(logger == null) return;
			
			if(!additionnalMessages)
				additionnalMessages = [];
			
			logger((logPrefix && logPrefix.length > 0 ? logPrefix + " " : "") + message + " " + additionnalMessages.join(" "));
		}
		
		/**
		 * Bubbles the received native log to ActionScript.
		 */
		private static function bubbleNativeLog(ev:StatusEvent):void {
			if(ev.code != EVENT_LOG) return;
			log(ev.level);
		}
	}
}