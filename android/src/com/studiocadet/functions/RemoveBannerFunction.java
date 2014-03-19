package com.studiocadet.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.studiocadet.InneractiveExtension;

public class RemoveBannerFunction implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		InneractiveExtension.context.removeBanner();
		
		return null;
	}

}
