ANE-Inneractive
===============

Air native extension for Inneractive ads, on Android and iOS

Inneractive SDK Versions
---------

* iOS: 2.0.7
* Android: 4.0.3

Documentation
----------

The documentation is available under */doc/index.html*

Install
-------

For Android, you need to add this to your application XML descriptor :

```xml
<android>
    <manifestAdditions><![CDATA[
        <manifest android:installLocation="auto">
            
            ...

            <!-- Inneractive required permissions -->
			<uses-permission android:name="android.permission.INTERNET" />
			<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
			
			<!-- Inneractive optional permissions (improved targeting) -->
			<uses-permission android:name="android.permission.READ_PHONE_STATE" />
			<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
			<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
			<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
            
            ...

            <application>

                ...
                
                <!-- Inneractive interstitials -->
				<activity android:name="com.inneractive.api.ads.InneractiveFullScreenView"
						  android:configChanges="orientation|screenSize"
						  android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"
						  android:hardwareAccelerated="true"/>
                
            </application>

        </manifest>
    ]]></manifestAdditions>
</android>
```

Build
-----

An ANT build script is in the build folder if you want to recompile the ANE. You can separately rebuild each part (actionscript, android, ios, ane, and doc) using the different targets.