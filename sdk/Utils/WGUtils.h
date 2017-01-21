//
//  WGUtils.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>

@interface WGUtils : NSObject

+ (double) getCurrentTimeMillis;
+ (BOOL)isInternetAvailable;
+ (BOOL) isLoaderTimeout:(long)savedTime;
+ (BOOL) isAdOverClickerTimeout:(long)savedTime;
+ (BOOL) hasValidConfig;

+ (void) saveAdConfig:(NSString*)config;
+ (NSString*) getAdConfig;

+ (NSString*) getStringValue:(NSString*)key;
+ (void) setStringValue:(NSString*)key value:(NSString*)value;
+ (NSInteger) getIntValue:(NSString*)key;
+ (NSInteger) getIntValue:(NSString*)key defValue:(NSInteger)defValue;
+ (void) setIntValue:(NSString*)key value:(NSInteger)value;
+ (void) setBoolValue:(NSString*)key value:(BOOL)value;
+ (BOOL) getBoolValue:(NSString*)key;
+ (void) setFloatValue:(NSString*)key value:(float)value;
+ (float) getFloatValue:(NSString*)key;

@end
