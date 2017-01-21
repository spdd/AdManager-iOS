//
//  WGConfigLoader.m
//  WordGames
//
//  Created by Dmitry B on 01.03.16.
//
//

#import "WGConfigLoader.h"
#import "WGLogger.h"
#import "WGAdConstants.h"
#import "WGUtils.h"

@interface WGConfigLoader () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData* buffer;
@property (nonatomic, strong) NSURLConnection* connection;

@end

@implementation WGConfigLoader

- (id) init {
    self = [super init];
    if (self != nil) {
        [self setDefaultValuesForAdmobAggregator];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
    self.buffer = nil;
}

- (NSDictionary*) getDataDict:(NSString*)config {
    NSString* json;
    BOOL isLocalConfig = NO;
    if (!config) {
        json = [[NSUserDefaults standardUserDefaults] stringForKey:PKEY_GAME_ADCONFIG];
        isLocalConfig = YES;
    } else {
        json = config;
    }
    NSError* error = nil;
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
    
    if (error) {
        AODLOG_DEBUG(@"Config json error: %@", [error description]);
    } else {
        // save ad config for 24 hours (only from internet!), if ad config not available load from cache
        if(![WGUtils hasValidConfig] && !isLocalConfig) {
            AODLOG_DEBUG(@"Save Config");
            [WGUtils saveAdConfig:json];
        }
    }
    return result;
}

- (void)runTask {
    if ([WGUtils hasValidConfig]) {
        AODLOG_DEBUG(@"Config from cache: %@", [WGUtils getAdConfig]);
        [self.delegate onConfigLoaded:[self getDataDict:[WGUtils getAdConfig]]];
        return;
    }
    
    NSDictionary* config = [self getDataDict:nil];
    NSString* configFromUrl = config[@"config_from_url"];
    if (configFromUrl && [configFromUrl isEqualToString:@"0"]) {
        [self loadFromFile:nil];
        return;
    }
    
    NSString* urlString = config[@"config_url"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];

    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (self.connection) {
        self.buffer = [NSMutableData data];
        [self.connection start];
    } else {
        [self loadFromFile:nil];
    }
}

- (void)runTaskWithConfig:(NSString*)config {
    [self loadFromFile:config];
}

- (void) fetch {
    [self runTask];
}

- (void) setDefaultValuesForAdmobAggregator {
    [WGUtils setIntValue:PKEY_VIDEO_ADMOB_AGGR value:0];
    [WGUtils setIntValue:PKEY_INTERS_ADMOB_AGGR value:0];
}

- (NSString*) getConfigKey {
    NSArray *bundleIdentifiers = [[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."];
    NSString* prefix = [bundleIdentifiers.lastObject stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString* configKey = [NSString stringWithFormat:REM_CFG_ADCONFIG, prefix];
    return configKey;
}

- (void) loadFromFile:(NSString*)config {
    if (config == nil && [WGUtils hasValidConfig]) {
        AODLOG_DEBUG(@"Config from cache: %@", [WGUtils getAdConfig]);
        [self.delegate onConfigLoaded:[self getDataDict:[WGUtils getAdConfig]]];
        return;
    }
    
    NSDictionary *dataDict = [self getDataDict:config];
    
    if (!dataDict) {
        NSError* error = nil;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"response" ofType:@"json"];
        NSData* data = [NSData dataWithContentsOfFile:path];
        dataDict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
    }
    
    if (dataDict)
        [self.delegate onConfigLoaded:dataDict];
    else
        [self.delegate onConfigFailedToLoad:0];
}

#pragma NSURLConnectionDataDelegate Delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection) {
        AODLOG_DEBUG(@"%@",[connection description]);
    }
    @try {
        NSMutableDictionary *dataDict = nil;
        NSError* error = nil;
        
        if(self.buffer) {
            dataDict = [NSJSONSerialization JSONObjectWithData:self.buffer options: NSJSONReadingMutableContainers error: &error];
        }
        if (error || self.buffer == nil) {
            AODLOG_DEBUG(@"%@", [error description]);
            [self loadFromFile:nil];
            return;
        } else {
            NSString* config = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
            AODLOG_DEBUG(@"Config from custom URL: %@", config);
            [self loadFromFile:config];
        }
    }
    @catch (NSException *exception) {
        AODLOG_ERROR(@"%@",[exception description]);
        [self loadFromFile:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.buffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    AODLOG_FULL_BANNER(@"Request for: response status code : %ld", (long)[httpResponse statusCode]);
    long statusCode = [httpResponse statusCode];
    if (statusCode < 200 || statusCode >= 300) {
        [connection cancel];
        [self loadFromFile:nil];
        //[self.delegate onConfigFailedToLoad:(int)statusCode];
        return;
    }
    
    [self.buffer setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    AODLOG_FULL_BANNER(@"%@",[error description]);
    self.connection = nil;
    self.buffer = nil;
    //[self.delegate onConfigFailedToLoad:(int)[error code]];
    [self loadFromFile:nil];
}

#pragma mark - Internal

- (NSError *)errorForStatusCode:(NSInteger)statusCode {
    NSString *errorMessage = [NSString stringWithFormat:
                              NSLocalizedString(@"if3games returned status code %d.",
                                                @"Status code error"),
                              statusCode];
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                          forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"if3games.com" code:statusCode userInfo:errorInfo];
}

@end
