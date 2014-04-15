package com.studiocadet;

import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.inneractive.api.ads.InneractiveAd;
import com.inneractive.api.ads.InneractiveAd.IaOptionalParams;
import com.studiocadet.functions.DisplayBannerFunction;
import com.studiocadet.functions.FetchInterstitialFunction;
import com.studiocadet.functions.RemoveBannerFunction;
import com.studiocadet.functions.ShowInterstitialFunction;
import com.studiocadet.listeners.BannerListener;
import com.studiocadet.listeners.InterstitialListener;

public class InneractiveExtensionContext extends FREContext {
	
	// PROPERTIES :
	
	/** The app's main view. */
	public ViewGroup _mainView;
	
	/** The displayed banner layout container, if any. */
	public LinearLayout bannerLayout;
	/** The displayed banner, if any. */
	public InneractiveAd bannerAd;
	
	/** The displayed interstitial layout container, if any. */
	public LinearLayout interstitialLayout;
	/** Whether the last fetched interstitial is a paid ad or a house (free) ad. */
	public Boolean fetchedInterstitialIsPaidAd;
	
	
	// CONSTRUCTOR :
	/**
	 * Creates an InneractiveExtensionContext and initializes Inneractive SDK with the given app ID.
	 */
	public InneractiveExtensionContext() {
	}
	
	/**
	 * Returns the main view of the app.
	 */
	private ViewGroup getMainView() {
		if(_mainView == null)
			_mainView = (ViewGroup) ((ViewGroup) getActivity().findViewById(android.R.id.content)).getChildAt(0);
		return _mainView;
	}
	
	
	/////////////
	// BANNERS //
	/////////////
	
	/**
	 * Displays and stores a banner with the given parameters.	
	 */
	public void displayBanner(String appID, InneractiveAd.IaAdAlignment alignment, Integer refreshRate, String keywords, Integer age, String gender) {
		
		// Only one banner at a time !
		if(bannerAd != null || bannerLayout != null) {
			onBannerFailed("A banner is already displayed, remove it first.");
			return;
		}
		
		// Create ad :
		bannerAd = new InneractiveAd(getActivity(), appID, InneractiveAd.IaAdType.Banner, refreshRate);
		
		// Set meta data :
		bannerAd.setAdAlignment(alignment);
		if(keywords != null)
			bannerAd.setAdKeywords(keywords);
		if(age != null && age > 0)
			bannerAd.setAge(age);
		if(gender != null)
			bannerAd.setGender(gender);
		
		bannerAd.setInneractiveListener(new BannerListener());
		
		// Create container :
		bannerLayout = new LinearLayout(getActivity());
		bannerLayout.setGravity(getGravityFromAlignment(alignment));
		getMainView().addView(bannerLayout, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
		
		// Display banner :
		bannerLayout.addView(bannerAd);
		Log.i(InneractiveExtension.TAG, "Displayed banner. Align:" + alignment + ", refresh:" + refreshRate + ", " +
				"keywords:" + keywords + ", age:" + age + ", gender:" + gender);
	}
	
	/**
	 * Informs ActionScript that a banner display request has failed.
	 */
	public void onBannerFailed(String details) {
		dispatchStatusEventAsync("BANNER_FAILED", details);
	}
	
	/**
	 * Informs ActionScript that a banner display request has complete.
	 */
	public void onBannerReceived(Boolean isPaidAd) {
		dispatchStatusEventAsync("BANNER_DISPLAYED", isPaidAd.toString());
	}
	
	/**
	 * Removes any currently displayed banner.
	 */
	public void removeBanner() {
		if(bannerAd == null && bannerLayout == null)
			return;
		
		if(bannerAd != null) {
			bannerAd.cleanUp();
			bannerAd = null;
		}
		
		if(bannerLayout != null) {
			getMainView().removeView(bannerLayout);
			bannerLayout = null;
		}
		
		Log.i(InneractiveExtension.TAG, "Removed displayed banner.");
	}
	
	
	///////////////////
	// INTERSTITIALS //
	///////////////////
	
	/**
	 * Prefetches an interstitial ad with the given targeting parameters.
	 */
	public void fetchInterstitial(String appID, String keywords, Integer age, String gender) {
		
		// Check for a previously fetched and unused interstitial :
		if(InneractiveAd.isInterstitialReady()) {
			Log.i(InneractiveExtension.TAG, "An interstitial ad is already ready. Aborting fetch.");
			onInterstitialFetched(fetchedInterstitialIsPaidAd);
			return;
		}
		
		// Create ad size meta data :
		Hashtable<IaOptionalParams, String> metaData = new Hashtable<InneractiveAd.IaOptionalParams, String>();
		if(appID.indexOf("AndroidTablet") > -1) {
			Log.i(InneractiveExtension.TAG, "Device is an android tablet, requesting a 768x1024 interstitial ad.");
			metaData.put(InneractiveAd.IaOptionalParams.Key_RequiredAdWidth, "768");
			metaData.put(InneractiveAd.IaOptionalParams.Key_RequiredAdHeight, "1024");
		}
		else {
			Log.i(InneractiveExtension.TAG, "Device is an android phone, requesting a 320x480 interstitial ad.");
			metaData.put(InneractiveAd.IaOptionalParams.Key_RequiredAdWidth, "320");
			metaData.put(InneractiveAd.IaOptionalParams.Key_RequiredAdHeight, "480");
		}
		
		// Add targeting keywords :
		if(keywords != null)
			metaData.put(InneractiveAd.IaOptionalParams.Key_Keywords, keywords);
		if(age != null && age > 0)
			metaData.put(InneractiveAd.IaOptionalParams.Key_Age, age.toString());
		if(gender != null)
			metaData.put(InneractiveAd.IaOptionalParams.Key_Gender, gender);
		
		// Fetch an interstitial :
		Log.i(InneractiveExtension.TAG, "Fetching an interstitial ad. Keywords:" + keywords + ", age:" + age + ", gender:" + gender);
		fetchedInterstitialIsPaidAd = null;
		Boolean networkAvailable = InneractiveAd.loadInterstitialAd(getActivity(), appID, metaData , new InterstitialListener());
		
		if(!networkAvailable) {
			Log.i(InneractiveExtension.TAG, "No network available, fetching failed.");
			onInterstitialFetchFailed("No network available.");
		}
	}
	
	/**
	 * Informs ActionScript that a fetchInterstitial() operation failed.
	 */
	public void onInterstitialFetchFailed(String details) {
		dispatchStatusEventAsync("INTERSTITIAL_FETCHED_FAILED", details);
	}
	
	/**
	 * Informs ActionScript that a fetchInterstitial() operation is complete.
	 */
	public void onInterstitialFetched(Boolean isPaidAd) {
		fetchedInterstitialIsPaidAd = isPaidAd;
		dispatchStatusEventAsync("INTERSTITIAL_FETCHED", isPaidAd.toString());
	}
	
	/**
	 * Informs ActionScript that an interstitial has been clicked.
	 */
	public void onInterstitialClicked() {
		dispatchStatusEventAsync("INTERSTITIAL_CLICKED", "");
		removeInterstitial();
	}
	
	/**
	 * Informs ActionScript that an interstitial has been dismissed.
	 */
	public void onInterstitialDismissed() {
		dispatchStatusEventAsync("INTERSTITIAL_DISMISSED", "");
		removeInterstitial();
	}
	
	/**
	 * Displays a previously fetched interstitial ad and returns true if it succeeded.
	 */
	public Boolean showInterstitial() {
		
		// Check an interstitial is fetched :
		if(!InneractiveAd.isInterstitialReady()) {
			Log.i(InneractiveExtension.TAG, "No interstitial ready, aborting display.");
			return false;
		}
		
		// Create the interstitial layout :
		interstitialLayout = new LinearLayout(getActivity());
		interstitialLayout.setGravity(Gravity.CENTER);
		interstitialLayout.setBackgroundColor(0xAA000000);
		interstitialLayout.setOnTouchListener(new View.OnTouchListener() { // -> avoid passing touches to underlying views while the ad is displayed
			@Override public boolean onTouch(View v, MotionEvent event) {
				return true;
			}
		});
		getMainView().addView(interstitialLayout, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
		
		// Displays the interstitial ad :
		Log.i(InneractiveExtension.TAG, "Displaying the previously fetched interstitial.");
		InneractiveAd.showInterstitialAd(getActivity());
		
		return true;
	}
	
	/**
	 * Removes the currently displayed interstitial layout.
	 */
	private void removeInterstitial() {
		if(interstitialLayout != null) {
			getMainView().removeView(interstitialLayout);
			interstitialLayout = null;
			InneractiveAd.cleanInterstitialAd();
			Log.i(InneractiveExtension.TAG, "Interstitial layout removed.");
		}
	}
	
	/////////////////
	// FRE METHODS //
	/////////////////


	/**
	 * Disposes the extension context instance.
	 */
	@Override
	public void dispose() {
		Log.i(InneractiveExtension.TAG, "Context disposed.");
	}

	/**
	 * Declares the functions mappings.
	 */
	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
		
		functions.put("ia_displayBanner", new DisplayBannerFunction());
		functions.put("ia_removeBanner", new RemoveBannerFunction());
		functions.put("ia_fetchInterstitial", new FetchInterstitialFunction());
		functions.put("ia_showInterstitial", new ShowInterstitialFunction());
		
		Log.i(InneractiveExtension.TAG, functions.size() + " extension functions declared.");
		
		return functions;
	}
	
	
	///////////
	// UTILS //
	///////////
	
	/**
	 * Returns a matching gravity to apply to a container given an Inneractive alignment.
	 */
	private int getGravityFromAlignment(InneractiveAd.IaAdAlignment alignment) {
		if(alignment.equals(InneractiveAd.IaAdAlignment.BOTTOM_CENTER))
			return Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
		if(alignment.equals(InneractiveAd.IaAdAlignment.BOTTOM_LEFT))
			return Gravity.BOTTOM | Gravity.LEFT;
		if(alignment.equals(InneractiveAd.IaAdAlignment.BOTTOM_RIGHT))
			return Gravity.BOTTOM | Gravity.RIGHT;
		if(alignment.equals(InneractiveAd.IaAdAlignment.CENTER))
			return Gravity.CENTER;
		if(alignment.equals(InneractiveAd.IaAdAlignment.CENTER_LEFT))
			return Gravity.CENTER_VERTICAL | Gravity.LEFT;
		if(alignment.equals(InneractiveAd.IaAdAlignment.CENTER_RIGHT))
			return Gravity.CENTER_VERTICAL | Gravity.RIGHT;
		if(alignment.equals(InneractiveAd.IaAdAlignment.TOP_CENTER))
			return Gravity.TOP | Gravity.CENTER_HORIZONTAL;
		if(alignment.equals(InneractiveAd.IaAdAlignment.TOP_LEFT))
			return Gravity.TOP | Gravity.LEFT;
		if(alignment.equals(InneractiveAd.IaAdAlignment.TOP_RIGHT))
			return Gravity.TOP | Gravity.RIGHT;
		
		return Gravity.NO_GRAVITY;
	}
}
