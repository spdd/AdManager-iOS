//
//  WGInterstitialCustomEvent.m
//  AdManager
//
//  Created by Dmitry B on 09.01.17.
//  Copyright © 2017 if3. All rights reserved.
//

#import "WGInterstitialCustomEvent.h"

// The default implementation of this methods does nothing. Subclasses must override this methods
// and implement code to load a banner here.

@implementation WGInterstitialCustomEvent

- (NSString*) getName {
    // Subclasses may override this method
    return @"noname";
}

- (void) initAd:(NSDictionary*)paramDict {
    // Subclasses may override this method
}

- (BOOL) isAvailable {
    // Subclasses may override this method
    return NO;
}

- (BOOL) isCached {
    // Subclasses may override this method
    return NO;
}

- (BOOL) isAutoLoadingVideo {
    // Subclasses may override this method
    return NO;
}

- (void) showInterstitial:(UIViewController*)rootController {
    // Subclasses may override this method
}

- (void) showVideo:(UIViewController*)rootController {
    // Subclasses may override this method
}

- (void) onStart {}
- (void) onStop {}
- (void) onDestroy {}
- (void) onPause {}
- (void) onResume {}
- (BOOL) isNativeSDK { return NO; }

@end
