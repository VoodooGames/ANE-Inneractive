package com.studiocadet.listeners;

import android.util.Log;

import com.inneractive.api.ads.InneractiveAdListener;
import com.studiocadet.InneractiveExtension;

public class BannerListener implements InneractiveAdListener {

	@Override
	public void onIaAdClicked() {
		Log.i(InneractiveExtension.TAG, "Banner ad clicked");
	}

	@Override
	public void onIaAdExpand() {
		Log.i(InneractiveExtension.TAG, "Banner ad expanded");
	}

	@Override
	public void onIaAdExpandClosed() {
		Log.i(InneractiveExtension.TAG, "Banner ad expand closed");
	}

	@Override
	public void onIaAdFailed() {
		Log.i(InneractiveExtension.TAG, "Banner ad failed");
		InneractiveExtension.context.onBannerFailed("Inneractive SDK failed to receive a banner");
	}

	@Override
	public void onIaAdReceived() {
		Log.i(InneractiveExtension.TAG, "Banner ad received a paid ad");
		InneractiveExtension.context.onBannerReceived(true);
	}

	@Override
	public void onIaAdResize() {
		Log.i(InneractiveExtension.TAG, "Banner ad resized");
	}

	@Override
	public void onIaAdResizeClosed() {
		Log.i(InneractiveExtension.TAG, "Banner ad resize closed");
	}

	@Override
	public void onIaDefaultAdReceived() {
		Log.i(InneractiveExtension.TAG, "Banner ad received a house ad");
		InneractiveExtension.context.onBannerReceived(false);
	}

}
