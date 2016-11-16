/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"

#import "RNSonomaCrashes.h"


// For TestCrash 
#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
#import "RCTBridgeModule.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTRootView.h"
#import "RCTUtils.h" 

@import SonomaCore;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  
  [SNMSonoma setServerUrl:@"https://in-integration.dev.avalanch.es"];
  //[SNMSonoma start:@"ce97bf46-2fbf-446f-a12a-8716dd1225a9" withFeatures:@[[SNMAnalytics class], [SNMCrashes class]]];
  [SNMSonoma setLogLevel: SNMLogLevelVerbose];
  [RNSonomaCrashes registerWithCrashDelegate:[[RNSonomaCrashesDelegateAlwaysSend alloc] init]];
  //[RNSonomaCrashes register];

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"RNCrashTest"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end


@interface TestCrash : NSObject <RCTBridgeModule>

@end

@implementation TestCrash
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(crash:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  int *crashme = (void *)0;
  while((*crashme++ = 0)) {

  }
}
@end 