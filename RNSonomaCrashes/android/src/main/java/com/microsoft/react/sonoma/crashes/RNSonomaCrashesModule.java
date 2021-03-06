package com.microsoft.sonoma.react.crashes;

import android.app.Application;
import android.util.Log;

import com.facebook.react.bridge.BaseJavaModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeMap;

import com.microsoft.sonoma.core.Sonoma;
import com.microsoft.sonoma.crashes.Crashes;
import com.microsoft.sonoma.crashes.model.ErrorReport;

import com.microsoft.sonoma.react.core.RNSonomaCore;

import org.json.JSONException;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNSonomaCrashesModule< CrashListenerType extends RNSonomaCrashesListenerBase > extends BaseJavaModule {
    private CrashListenerType mCrashListener;

    private static final String HasCrashedInLastSessionKey = "hasCrashedInLastSession";
    private static final String LastCrashReportKey = "lastCrashReport";

    public RNSonomaCrashesModule(Application application, CrashListenerType crashListener) {
        this.mCrashListener = crashListener;
        if (crashListener != null) {
            Crashes.setListener(crashListener);
        }

        RNSonomaCore.initializeSonoma(application);
        Sonoma.start(Crashes.class);
    }

    public void setReactApplicationContext(ReactApplicationContext reactContext) {
        RNSonomaCrashesUtils.logDebug("Setting react context");
        if (this.mCrashListener != null) {
            this.mCrashListener.setReactApplicationContext(reactContext);
        }
    }

    @Override
    public String getName() {
        return "RNSonomaCrashes";
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        ErrorReport lastError = Crashes.getLastSessionCrashReport();
        
        constants.put(RNSonomaCrashesModule.HasCrashedInLastSessionKey, lastError != null);
        if (lastError != null) {
            constants.put(RNSonomaCrashesModule.LastCrashReportKey, RNSonomaCrashesUtils.convertErrorReportToWritableMapOrEmpty(lastError));
        }

        return constants;
    }

    @ReactMethod
    public void getCrashReports(Promise promise) {
        List<ErrorReport> pendingReports = this.mCrashListener.getAndClearReports();
        promise.resolve(RNSonomaCrashesUtils.convertErrorReportsToWritableArrayOrEmpty(pendingReports));
    }

    @ReactMethod
    public void setEnabled(boolean shouldEnable) {
        Crashes.setEnabled(shouldEnable);
    }

    @ReactMethod
    public void isEnabled(Promise promise) {
        promise.resolve(Crashes.isEnabled());
    }

    @ReactMethod
    public void generateTestCrash(final Promise promise) {
        new Thread(new Runnable() {
            public void run() {
                Crashes.generateTestCrash();
                promise.reject(new Exception("generateTestCrash failed to generate a crash"));
            }
        }).start();
    }

    @ReactMethod 
    public void crashUserResponse(boolean send, ReadableMap attachments, Promise promise) {
        int response = send ? Crashes.SEND : Crashes.DONT_SEND;
        if (mCrashListener != null) {
            mCrashListener.reportUserResponse(response);
            mCrashListener.provideAttachments(attachments);
        }
        Crashes.notifyUserConfirmation(response);
        promise.resolve("");
    }
}
