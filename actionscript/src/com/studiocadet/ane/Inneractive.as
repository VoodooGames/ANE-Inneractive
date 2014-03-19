package com.studiocadet.ane {
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
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
		private static const SIZE_ANDROID_TABLET:Point = new Point(728, 90);
		private static const SIZE_IPAD:Point = new Point(728, 90);
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
		/** The shortened app ID. */
		private static var appID:String;
		/** The device type. */
		private static var deviceType:String;
		/** The banner size. */
		private static var bannerSize:Point;
		
		
		/**
		 * Initializes the extension with the given shortened app ID and the given device type.
		 * 
		 */
		public static function init(shortenedAppID:String, deviceType:String= null):void {
			
			if(context)
				throw new Error("Inneractive should only be initialized once !");
			
			if(deviceType == null) {
				if(Capabilities.os.indexOf("iPhone") > -1)
					deviceType = DEVICE_TYPE_IPHONE;
				else if(Capabilities.os.indexOf("iPad") > -1)
					deviceType = DEVICE_TYPE_IPAD;
				else 
					deviceType = Math.min(Capabilities.screenResolutionX, Capabilities.screenResolutionY) <= 768 ? DEVICE_TYPE_ANDROID : DEVICE_TYPE_ANDROID_TABLET;
				log("Detected device type : " + deviceType);
			}
			
			// Iniitialize AS part :
			Inneractive.appID = shortenedAppID;
			Inneractive.deviceType = deviceType;
			
			if(deviceType == DEVICE_TYPE_ANDROID)
				bannerSize = SIZE_ANDROID;
			else if(deviceType == DEVICE_TYPE_ANDROID_TABLET)
				bannerSize = SIZE_ANDROID_TABLET;
			else if(deviceType == DEVICE_TYPE_IPAD)
				bannerSize = SIZE_IPAD;
			else 
				bannerSize = SIZE_IPHONE;
			
			// Initialize the native part :
			log("Initializing Inneractive extension with app ID : " + shortenedAppID + "_" + deviceType + " ...");
			context = ExtensionContext.createExtensionContext(EXTENSION_ID, shortenedAppID + "_" + deviceType);
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
		 * @param alignment		One of the ALIGN_* constants
		 * @param refreshRate	The number of seconds between ad refreshes (min:15, max:300)
		 * @param onSuccess		Called when the banner is displayed. Signature : function(isPaidAd:Boolean):void
		 * @param onFailure		Called when displaying the banner fails for any reason. Signature : function():void
		 * @param keywords		Relevant keywords for ad targeting. For example: cars,music,sports (comma separated, w/o spaces)
		 * @param age			The user's age (between 1 and 120). Leave to -1 to ignore this parameter
		 * @param gender		The user's gender. One of the GENDER_* constants
		 */
		public static function displayBanner(alignment:String, refreshRate:uint, onSuccess:Function, onFailure:Function, 
											 keywords:String = null, age:int = -1, gender:String = null):void 
		{
			// Check parameters :
			if(ALIGNMENTS.indexOf(alignment) == -1) 
				throw new Error("Invalid alignment : " + alignment);
			if(refreshRate < 15 || refreshRate > 300)
				throw new Error("Invalid refresh rate : " + refreshRate + " (min:15, max:300)");
			if(age == 0 || age > 120)
				throw new Error("Invalid age : " + age + " (min:1, max:120, ignore:<0)");
			if(gender && gender != GENDER_F && gender != GENDER_M)
				throw new Error("Invalid gender : " + gender + ". Use one of the GENDER_* constants.");
			
			// Prepare callbacks :
			context.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			context.call("ia_displayBanner", alignment, refreshRate, keywords, age, gender);
			log("Displaying banner (align:" + alignment + ", refreshRate:" + refreshRate + "s)");
			
			// Banner display callbacks :
			function onStatus(ev:StatusEvent):void {
				if(ev.code == EVENT_BANNER_DISPLAYED) {
					log("Banner displayed (is paid ? " + ev.level + ")");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onSuccess != null)
						onSuccess(Boolean(ev.level));
				}
				else if(ev.code == EVENT_BANNER_FAILED) {
					log("Banner failed to display : " + ev.level);
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onFailure != null)
						onFailure();
				}
			}
		}
		
		/**
		 * Returns the banner's size. This method will work as long as the extension has been initialized.
		 */
		public static function getBannerSize():Point {
			return bannerSize;
		}
		
		/**
		 * Removes the currently displayed banner.
		 */
		public static function removeBanner():void {
			context.call("ia_removeBanner");
			log("Banner removed.");
		}
		
		
		//////////////////
		// INTERSTITIAL //
		//////////////////
		
		/**
		 * Fetches an interstitial ad with the given parameters.
		 * 
		 * @param onFetched	Called when the ad is successfully fetched. Signature : function():void
		 * @param onFailure	Called when the ad fails to be fetched. Signature : function(errorMessage:String):void
		 * @param keywords	Relevant keywords for ad targeting. For example: cars,music,sports (comma separated, w/o spaces)
		 * @param age		The user's age (between 1 and 120). Leave to -1 to ignore this parameter
		 * @param gender	The user's gender. One of the GENDER_* constants
		 */
		public static function fetchInterstitial(onFetched:Function, onFailure:Function, keywords:String = null, age:int = -1, gender:String = null):void {
			
			if(age == 0 || age > 120)
				throw new Error("Invalid age : " + age + " (min:1, max:120, ignore:<0)");
			if(gender && gender != GENDER_F && gender != GENDER_M)
				throw new Error("Invalid gender : " + gender + ". Use one of the GENDER_* constants.");
			
			context.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			context.call("ia_fetchInterstitial", keywords, age, gender);
			log("Fetching an interstitial ...");
			
			function onStatus(ev:StatusEvent):void {
				if(ev.code == EVENT_INTERSTITIAL_FETCHED) {
					log("Interstitial fetched succcessfully.");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onFetched != null)
						onFetched();
				}
				else if(ev.code == EVENT_INTERSTITIAL_FETCH_FAILED) {
					log("Interstitial fetch failed.");
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
		public static function showInterstitial(onDismiss:Function, onClick:Function):void {
			context.addEventListener(StatusEvent.STATUS, onStatus, false, 0, true);
			context.call("ia_showInterstitial");
			log("Showing the fetched interstitial.");
			
			function onStatus(ev:StatusEvent):void {
				if(ev.code == EVENT_INTERSTITIAL_CLICKED) {
					log("Interstitial clicked.");
					if(onClick != null)
						onClick();
				}
				if(ev.code == EVENT_INTERSTITIAL_DISMISSED) {
					log("Interstitial dismissed.");
					context.removeEventListener(StatusEvent.STATUS, arguments.callee);
					if(onDismiss != null)
						onDismiss();
				}
			}
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
			
			logger(message + " " + additionnalMessages.join(" "));
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