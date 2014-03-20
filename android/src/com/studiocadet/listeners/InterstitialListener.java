package com.studiocadet.listeners;

import android.util.Log;

import com.inneractive.api.ads.InneractiveInterstitialAdListener;
import com.studiocadet.InneractiveExtension;

public class InterstitialListener implements InneractiveInterstitialAdListener {

	@Override
	public void onIaDefaultInterstitialAdLoaded() {
		Log.i(InneractiveExtension.TAG, "Interstitial house ad fetched.");
		InneractiveExtension.context.onInterstitialFetched(false);
	}

	@Override
	public void onIaDismissScreen() {
		Log.i(InneractiveExtension.TAG, "Interstitial ad dismissed.");
		InneractiveExtension.context.onInterstitialDismissed();
	}

	@Override
	public void onIaFailedToLoadInterstitialAd() {
		Log.i(InneractiveExtension.TAG, "Interstitial ad fetch failed.");
		InneractiveExtension.context.onInterstitialFetchFailed("Inneractive SDK failed to fetch an interstitial.");
	}

	@Override
	public void onIaInterstitialAdClicked() {
		Log.i(InneractiveExtension.TAG, "Interstitial ad clicked.");
		InneractiveExtension.context.onInterstitialClicked();
	}

	@Override
	public void onIaInterstitialAdLoaded() {
		Log.i(InneractiveExtension.TAG, "Interstitial paid ad fetched.");
		InneractiveExtension.context.onInterstitialFetched(true);
	}

}
