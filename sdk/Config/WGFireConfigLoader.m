//
//  WGFireConfigLoader.m
//  Unity-iPhone
//
//  Created by Dmitry B on 17.01.17.
//
//

#import "WGFireConfigLoader.h"
#import <FirebaseRemoteConfig/FirebaseRemoteConfig.h>

@implementation WGFireConfigLoader

- (void) fetch {
    FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    remoteConfig.configSettings = remoteConfigSettings;
    [remoteConfig fetchWithExpirationDuration:0 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"Config fetched!");
            [remoteConfig activateFetched];
            
            NSString* configKey = [self getConfigKey];
            
            NSLog(@"configKey: %@", configKey);
            NSLog(@"Fire config: %@", remoteConfig[configKey].stringValue);
            if (remoteConfig[configKey].stringValue.length != 0) {
                [self runTaskWithConfig:remoteConfig[configKey].stringValue];
            } else {
                NSLog(@"Config not fetched");
                [self runTask];
            }
            
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
            [self runTask];
        }
    }];
}


@end
