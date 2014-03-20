package com.studiocadet;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

/**
 * The main extension file. Mainly instantiates the ExtensionContext.
 */
public class InneractiveExtension implements FREExtension {
	
	// PROPERTIES :
	
	/** The logging TAG. */
	public static String TAG = "Inneractive";
	
	/** The context instance. */
	public static InneractiveExtensionContext context;
	
	/** The female gender to use in Inneractive targeting parameters. */
	public static final String GENDER_F = "F";
	/** The male gender to use in Inneractive targeting parameters. */
	public static final String GENDER_M = "M";
	
	
	// METHODS :
	
	/**
	 * Creates a new extension context with the given app ID.
	 */
	@Override
	public FREContext createContext(String appID) {
		context = new InneractiveExtensionContext(appID);
		return context;
	}

	@Override
	public void dispose() {
		Log.i(TAG, "Extension disposed.");
		context = null;
	}

	@Override
	public void initialize() {
		Log.i(TAG, "Extension initialized.");
	}

}
