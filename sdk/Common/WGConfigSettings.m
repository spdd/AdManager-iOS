//
//  WGConfigSettings.m
//  AdManager
//
//  Created by Dmitry B on 20.01.17.
//  Copyright © 2017 if3. All rights reserved.
//

#import "WGConfigSettings.h"
#import "WGUtils.h"
#import "WGAdConstants.h"

#define ST_AD_FR_SHOW @"ST_SHOW_AD_EVERY_LEVEL"
#define ST_CF_TIMEOUT @"ST_CONFIG_STORE_TIMEOUT"
#define ST_AC_TIMEOUT @"ST_ANTICLICKER_TIMEOUT"

@interface WGConfigSettings ()

@property (nonatomic) int adFreqShowEveryLevel;
@property (nonatomic) int storeAdConfigTimeOut;
@property (nonatomic) int antiClickerTimeOut;
@property (strong, nonatomic) NSDictionary* userParams;

@end

@implementation WGConfigSettings

+ (instancetype)sharedInstance {
    static WGConfigSettings* _instance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] initUniqueInstance];
        _instance.adFreqShowEveryLevel = SHOW_AD_EVERY_LEVEL;
        _instance.storeAdConfigTimeOut = CONFIG_STORE_TIMEOUT;
        _instance.antiClickerTimeOut = ANTICLICKER_TIMEOUT;
    });
    return _instance;
}

- (instancetype) initUniqueInstance {
    return [super init];
}

#pragma mark - settings

- (void) setupSettings:(NSDictionary*)params {
    int par1 = params[@"show_freq"] ? [params[@"show_freq"] intValue] : -1;
    int par2 = params[@"conf_timeout"] ? [params[@"conf_timeout"] intValue] : -1;
    int par3 = params[@"anti_click_timeout"] ? [params[@"anti_click_timeout"] intValue] : -1;
    
    if (par1 > 0) [WGUtils setIntValue:ST_AD_FR_SHOW value:par1];
    if (par2 > 0) [WGUtils setIntValue:ST_CF_TIMEOUT value:par2];
    if (par3 > 0) [WGUtils setIntValue:ST_AC_TIMEOUT value:par3];
    
    if (params[@"user_params"]) {
        NSArray* array = params[@"user_params"];
        self.userParams = [array objectAtIndex:0];
    }
}

- (int) createAdFreqShowEveryLevel {
    int result = (int)[WGUtils getIntValue:ST_AD_FR_SHOW];
    if (result == 0)
        return self.adFreqShowEveryLevel;
    return result;
}

- (int) createStoreAdConfigTimeOut {
    int result = (int)[WGUtils getIntValue:ST_CF_TIMEOUT];
    if (result == 0)
        return self.storeAdConfigTimeOut;
    return result;
}

- (int) createAntiClickerTimeOut {
    int result = (int)[WGUtils getIntValue:ST_AC_TIMEOUT];
    if (result == 0)
        return self.antiClickerTimeOut;
    return result;
}

- (NSString*) createStringUserCustomSetting:(NSString*)paramName {
    if (self.userParams) {
        return self.userParams[paramName];
    }
    return nil;
}

- (int) createIntUserCustomSetting:(NSString*)paramName {
    if (self.userParams) {
        return [self.userParams[paramName] intValue];
    }
    return 0;
}

@end
