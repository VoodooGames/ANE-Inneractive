package com.studiocadet.utils;

import com.adobe.fre.FREObject;

/**
 * A set of tools to ease working with FRE objects.
 */
public class FREUtils {
	
	/**
	 * Safely tries to get a string argument at the given index. If something goes wrong, null is returned.
	 */
	public static String getString(FREObject[] args, int index) {
		if(args == null || args != null && args.length <= index)
			return null;
		
		String s = null;
		
		try {
			s = args[index].getAsString();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return s;
	}
	
	/**
	 * Safely tries to get an integer argument at the given index. If something goes wrong, null is returned.
	 */
	public static Integer getInteger(FREObject[] args, int index) {
		if(args == null || args != null && args.length <= index)
			return null;
		
		Integer i = null;
		
		try {
			i = args[index].getAsInt();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return i;
	}
	
	/**
	 * Safely tries to get a boolean argument at the given index. If something goes wrong, null is returned.
	 */
	public static Boolean getBoolean(FREObject[] args, int index) {
		if(args == null || args != null && args.length <= index)
			return null;
		
		Boolean b = null;
		
		try {
			b = args[index].getAsBool();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return b;
	}
	
	/**
	 * Safely tries to get a double argument at the given index. If something goes wrong, null is returned.
	 */
	public static Double getDouble(FREObject[] args, int index) {
		if(args == null || args != null && args.length <= index)
			return null;
		
		Double d = null;
		
		try {
			d = args[index].getAsDouble();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return d;
	}
}
