//
//  WGConfigSettings.h
//  AdManager
//
//  Created by Dmitry B on 20.01.17.
//  Copyright © 2017 if3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WGConfigSettings : NSObject

+ (instancetype) sharedInstance;
- (void) setupSettings:(NSDictionary*)params;
- (int) createAdFreqShowEveryLevel;
- (int) createStoreAdConfigTimeOut;
- (int) createAntiClickerTimeOut;
- (NSString*) createStringUserCustomSetting:(NSString*)paramName;
- (int) createIntUserCustomSetting:(NSString*)paramName;

@end
