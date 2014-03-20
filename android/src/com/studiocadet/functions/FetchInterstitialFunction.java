package com.studiocadet.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.studiocadet.InneractiveExtension;
import com.studiocadet.utils.FREUtils;

public class FetchInterstitialFunction implements FREFunction {
	
	/**
	 * Expected arguments : keywords, age, gender
	 */
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		// Get calling parameters :
		String keywords = FREUtils.getString(args, 0);
		Integer age = FREUtils.getInteger(args, 1);
		String gender = FREUtils.getString(args, 2);
		
		// Enforce parameters values :
		if(age != null && age < 0)
			age = null;
		
		if(gender != null && !gender.equals(InneractiveExtension.GENDER_F) && !gender.equals(InneractiveExtension.GENDER_M))
			gender = null;
		
		// Call the method :
		InneractiveExtension.context.fetchInterstitial(keywords, age, gender);
		
		return null;
	}

}
