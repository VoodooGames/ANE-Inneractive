package com.studiocadet.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.inneractive.api.ads.InneractiveAd;
import com.studiocadet.InneractiveExtension;
import com.studiocadet.utils.FREUtils;

public class DisplayBannerFunction implements FREFunction {
	
	// STRING ALIGNMENT IN ACTIONSCRIPT :
	private static final String ALIGN_BOTTOM_CENTER = "BOTTOM_CENTER";
	private static final String ALIGN_BOTTOM_LEFT = "BOTTOM_LEFT";
	private static final String ALIGN_BOTTOM_RIGHT = "BOTTOM_RIGHT";
	private static final String ALIGN_CENTER = "CENTER";
	private static final String ALIGN_CENTER_LEFT = "CENTER_LEFT";
	private static final String ALIGN_CENTER_RIGHT = "CENTER_RIGHT";
	private static final String ALIGN_TOP_CENTER = "TOP_CENTER";
	private static final String ALIGN_TOP_LEFT = "TOP_LEFT";
	private static final String ALIGN_TOP_RIGHT = "TOP_RIGHT";
	
	/**
	 * Expected arguments : alignment, refreshRate, keywords, age, gender
	 */
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		// Get calling parameters :
		String stringAlignment = FREUtils.getString(args, 0);
		Integer refreshRate = FREUtils.getInteger(args, 1);
		String keywords = FREUtils.getString(args, 2);
		Integer age = FREUtils.getInteger(args, 3);
		String gender = FREUtils.getString(args, 4);
		
		// Enforce parameters values :
		InneractiveAd.IaAdAlignment alignment = null;
		if(stringAlignment.equals(ALIGN_BOTTOM_CENTER))
			alignment = InneractiveAd.IaAdAlignment.BOTTOM_CENTER;
		else if(stringAlignment.equals(ALIGN_BOTTOM_LEFT))
			alignment = InneractiveAd.IaAdAlignment.BOTTOM_LEFT;
		else if(stringAlignment.equals(ALIGN_BOTTOM_RIGHT))
			alignment = InneractiveAd.IaAdAlignment.BOTTOM_RIGHT;
		else if(stringAlignment.equals(ALIGN_CENTER))
			alignment = InneractiveAd.IaAdAlignment.CENTER;
		else if(stringAlignment.equals(ALIGN_CENTER_LEFT))
			alignment = InneractiveAd.IaAdAlignment.CENTER_LEFT;
		else if(stringAlignment.equals(ALIGN_CENTER_RIGHT))
			alignment = InneractiveAd.IaAdAlignment.CENTER_RIGHT;
		else if(stringAlignment.equals(ALIGN_TOP_CENTER))
			alignment = InneractiveAd.IaAdAlignment.TOP_CENTER;
		else if(stringAlignment.equals(ALIGN_TOP_LEFT))
			alignment = InneractiveAd.IaAdAlignment.TOP_LEFT;
		else if(stringAlignment.equals(ALIGN_TOP_RIGHT))
			alignment = InneractiveAd.IaAdAlignment.TOP_RIGHT;
		
		if(refreshRate < 15)
			refreshRate = 15;
		if(refreshRate > 300)
			refreshRate = 300;
		
		if(age != null && age < 0)
			age = null;
		
		if(gender != null && !gender.equals(InneractiveExtension.GENDER_F) && !gender.equals(InneractiveExtension.GENDER_M))
			gender = null;
		
		// Call the method :
		InneractiveExtension.context.displayBanner(alignment, refreshRate, keywords, age, gender);
		
		return null;
	}

}
