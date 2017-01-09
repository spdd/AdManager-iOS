//
//  WGAdObject.m
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import "WGAdObject.h"
#import "WGTypes.h"

@interface WGAdObject ()

@property (nonatomic, readwrite) BOOL isFailed;
@property (nonatomic) int failedCounter;
@property (nonatomic) int loadCounter;
@property (nonatomic) int cost;
@property (nonatomic) int initCost;
@property (nonatomic) int clickCounter;
@property (nonatomic) double loadedEcpm;
@property (nonatomic, readwrite) double priceFloor;
@property (nonatomic, readwrite) int loaderTime;
@property (nonatomic) int tryLoaderCounter;
@property (nonatomic, readwrite) BOOL isVideoCached;
@property (nonatomic, strong) NSString* adName;
@property (nonatomic, weak) id<WGAdObjectDelegate> delegate;

@end

@implementation WGAdObject

- (id)initWithData:(NSDictionary*)requestData cost:(int)cost delegate:(id<WGAdObjectDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.requestData = requestData;
        self.delegate = delegate;
        self.isFailed = NO;
        self.isVideoCached = NO;
        self.isPrecache = NO;
        self.tryLoaderCounter = 0;
        self.failedCounter = 0;
        self.loadCounter = 0;
        self.loaderTime = 12;
        self.clickCounter = 0;
        if (requestData[@"adname"] && [requestData[@"adname"] isEqualToString:@"vungle"]) {
            self.loaderTime = 22;
        }
        if (requestData[@"adname"] && [requestData[@"adname"] isEqualToString:@"applovin"]) {
            self.loaderTime = 20;
        }
        if (requestData[@"adname"] && [requestData[@"adname"] isEqualToString:@"adcolony"]) {
            self.loaderTime = 15;
        }
        if (requestData[@"adname"])
            self.adName = requestData[@"adname"];
        
        self.cost = cost;
        self.initCost = cost;
        self.loadedEcpm = requestData[@"ecpm"] ? [requestData[@"ecpm"] doubleValue] : 0.0;
        self.priceFloor = requestData[@"price_floor"] ? [requestData[@"price_floor"] doubleValue] : -1.0;
    }
    return self;
}

- (void)dealloc {
    self.requestData = nil;
    self.delegate = nil;
}

- (NSString*)getAdName {
    return self.adName;
}

- (void) setClicketAd {
    self.clickCounter++;
    if (!self.isPrecache && [self.delegate getAdType] != WGAdTypeVideo && self.clickCounter >= 2) {
        self.isFailed = true;
        [self.delegate onDisableNetwork:self.adName];
    }
}

- (void)setLoadedAd:(BOOL)loaded {
    if (!loaded) {
        if (self.delegate && [self.delegate getAdType] == WGAdTypeVideo) {
            self.isVideoCached = NO;
            self.failedCounter = 10;
            [self.delegate removeCachedVideo:self.adName];
        }
        self.failedCounter++;
        if (self.failedCounter >= 3) {
            self.isFailed = YES;
        }
        if(self.isFailed) {
            self.failedCounter++;
        }
        if (self.delegate && self.isPrecache) {
            [self.delegate onAdPrecacheFailedLoad];
            return;
        }
        if (self.delegate) {
            [self.delegate onAdFailedLoad];
        }
    } else {
        if (self.delegate && [self.delegate getAdType] == WGAdTypeVideo) {
            self.isVideoCached = YES;
            self.loaderTime = -1;
            [self.delegate addCachedVideo:self.adName];
        }
        self.loadCounter++;
        if (self.failedCounter >= 1) {
            self.failedCounter = 0;
        }
        if (self.delegate) {
            [self.delegate onAdLoaded:self];
        }
    }
    if (self.isPrecache) {
        return;
    }
    if (self.delegate) {
        [self.delegate refreshAdObjects];
    }
}

- (void)didVideoShown:(BOOL)shown {
    [self.delegate onAdLoaded:self];
    if (self.delegate) {
        [self.delegate refreshAdObjects];
    }
}

- (void)resetAd { // timeout reset (evoke from AODAdAgent)
    self.isFailed = NO;
    self.failedCounter = 0;
    self.loadCounter = 0;
    self.cost = self.initCost;
}

- (int)loadsCount {
    return self.loadCounter;
}

- (float)getCalculatedCost {
    float cost = (float)(1.0f/(1.0f + (self.failedCounter + self.cost)));
    return cost;
}

#pragma - mark Video Ads

- (void)setTryLoadingCount {
    self.tryLoaderCounter++;
}

- (int)getTryLoadingCount {
    return self.tryLoaderCounter;
}

- (void)cacheNextVideo {
    self.loaderTime = 12;
    self.isVideoCached = NO;
    self.tryLoaderCounter = 0;
}

#pragma mark - manipulate costs

- (void)setObjectToTop {
    self.failedCounter = 0;
    self.cost = 0;
    
    if (self.delegate) {
        [self.delegate refreshAdObjects];
    }
}

@end
