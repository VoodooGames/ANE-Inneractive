package com.studiocadet;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.inneractive.api.ads.InneractiveAd;
import com.studiocadet.functions.DisplayBannerFunction;
import com.studiocadet.functions.FetchInterstitialFunction;
import com.studiocadet.functions.RemoveBannerFunction;
import com.studiocadet.functions.ShowInterstitialFunction;
import com.studiocadet.listeners.BannerListener;

public class InneractiveExtensionContext extends FREContext {
	
	// PROPERTIES :
	/** The appID to use for ad requests. */
	public String appID;
	
	/** The app's main view. */
	public ViewGroup _mainView;
	
	/** The displayed banner layout container, if any. */
	public LinearLayout bannerLayout;
	/** The displayed banner, if any. */
	public InneractiveAd bannerAd;
	
	
	// CONSTRUCTOR :
	/**
	 * Creates an InneractiveExtensionContext and initializes Inneractive SDK with the given app ID.
	 */
	public InneractiveExtensionContext(String appID) {
		this.appID = appID;
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
	 * 
	 * @param alignment		
	 * @param refreshRate	
	 * @param keywords		
	 * @param age			
	 * @param gender		
	 */
	public void displayBanner(InneractiveAd.IaAdAlignment alignment, Integer refreshRate, String keywords, Integer age, String gender) {
		
		// Only one banner at a time !
		if(bannerAd != null || bannerLayout != null) {
			dispatchStatusEventAsync("BANNER_FAILED", "A banner is already displayed, remove it first.");
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
	 * Informs the ActionScript side that a banner display request has failed.
	 */
	public void onBannerFailed() {
		dispatchStatusEventAsync("BANNER_FAILED", "Inneractive SDK failed to receive a banner");
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
