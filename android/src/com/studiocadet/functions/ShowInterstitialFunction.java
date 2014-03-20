package com.studiocadet.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.studiocadet.InneractiveExtension;
import com.studiocadet.utils.FREUtils;

public class ShowInterstitialFunction implements FREFunction {
	
	/**
	 * Expected arguments : nothing.
	 */
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		Boolean interstitialDisplayed = InneractiveExtension.context.showInterstitial();
		
		return FREUtils.newObject(interstitialDisplayed);
	}

}
