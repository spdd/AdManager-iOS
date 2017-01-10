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
@import Firebase;

@interface WGConfigLoader () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData* buffer;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, weak) id<WGConfigLoaderDelegate> delegate;

@end

@implementation WGConfigLoader

+ (instancetype) initWithDelegate:(id<WGConfigLoaderDelegate>)delegate {
    WGConfigLoader* loader = [WGConfigLoader new];
    loader.delegate = delegate;
    [loader fetchFromFirebase];
    return loader;
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
    NSError* error = nil;
    NSString* json;
    if (!config)
        json = [[NSUserDefaults standardUserDefaults] stringForKey:PKEY_GAME_ADCONFIG];
    else
        json = config;
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
}

- (void)runTask {
    NSDictionary* config = [self getDataDict:nil];
    NSString* configFromUrl = config[@"config_from_url"];
    if (configFromUrl && [configFromUrl isEqualToString:@"0"]) {
        [self loadFromFile:nil];
        return;
    }
    
    NSString* urlString = config[@"config_url"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    /*
    if (!([urlString rangeOfString:@"parse"].location == NSNotFound)) {
        NSLog(@"Parse url is: %@", urlString);
        [request setValue:[[WGConstantsManager sharedInstance] getConstants].PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
        [request setValue:[[WGConstantsManager sharedInstance] getConstants].PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    } */

    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (self.connection) {
        self.buffer = [NSMutableData data];
        [self.connection start];
    } else {
        [self loadFromFile:nil];
        //[self.delegate onConfigFailedToLoad:0];
    }
}

- (void)runFirebaseTask:(NSString*)config {
    [self loadFromFile:config];
}

- (void) fetchFromFirebase {
    @try {
        FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
        FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
        remoteConfig.configSettings = remoteConfigSettings;
        [remoteConfig fetchWithExpirationDuration:0 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
            if (status == FIRRemoteConfigFetchStatusSuccess) {
                AODLOG_DEBUG(@"Config fetched!");
                [remoteConfig activateFetched];
                
                NSArray *bundleIdentifiers = [[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."];
                NSString* prefix = [bundleIdentifiers.lastObject stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSString* configKey = [NSString stringWithFormat:REM_CFG_ADCONFIG, prefix];
                //if (remoteConfig[@"ad_config_whatthewordrus"].stringValue.length > 0) {
                //    NSLog(@"configKey exists");
                //}
                AODLOG_DEBUG(@"configKey: %@", configKey);
                AODLOG_DEBUG(@"Fire config: %@", remoteConfig[configKey].stringValue);
                NSString* admobVideoAggrKey = [NSString stringWithFormat:REM_CFG_ADMOB_V_AGGR, prefix];
                NSString* admobIntersAggrKey = [NSString stringWithFormat:REM_CFG_ADMOB_I_AGGR, prefix];
                if (remoteConfig[admobVideoAggrKey])
                    [self savePrefValue:[remoteConfig[admobVideoAggrKey].numberValue integerValue] forKey:PKEY_VIDEO_ADMOB_AGGR];
                else
                    [self savePrefValue:0 forKey:PKEY_VIDEO_ADMOB_AGGR];
                if (remoteConfig[admobIntersAggrKey])
                    [self savePrefValue:[remoteConfig[admobIntersAggrKey].numberValue integerValue] forKey:PKEY_INTERS_ADMOB_AGGR];
                else
                    [self savePrefValue:0 forKey:PKEY_INTERS_ADMOB_AGGR];
                //NSLog(@"admobVideoAggrKey: %ld", [remoteConfig[admobVideoAggrKey].numberValue integerValue]);
                
                if (remoteConfig[configKey].stringValue.length != 0) {
                    [self runFirebaseTask:remoteConfig[configKey].stringValue];
                } else {
                    [self runTask];
                }

            } else {
                AODLOG(@"Config not fetched");
                AODLOG(@"Error %@", error.localizedDescription);
                [self savePrefValue:0 forKey:PKEY_VIDEO_ADMOB_AGGR];
                [self savePrefValue:0 forKey:PKEY_INTERS_ADMOB_AGGR];
                [self runTask];
            }
        }];
    } @catch (NSException *exception) {
        AODLOG(@"Config not fetched");
        AODLOG(@"Error %@", error.localizedDescription);
        [self savePrefValue:0 forKey:PKEY_VIDEO_ADMOB_AGGR];
        [self savePrefValue:0 forKey:PKEY_INTERS_ADMOB_AGGR];
        [self runTask];
    }

}

- (void) savePrefValue:(NSInteger)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadFromFile:(NSString*)config {
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
        if (error) {
            AODLOG_FULL_BANNER(@"%@", [error description]);
            [self loadFromFile:nil];
            //[self.delegate onConfigFailedToLoad:0];
        }
        AODLOG_FULL_BANNER(@"size: %lu\n%@", (unsigned long)[dataDict count], dataDict[@"params"][@"ad_config"]);
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:[dataDict[@"params"][@"ad_config"] dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        if (result) {
            [self.delegate onConfigLoaded:result];
        }
        else
            [self loadFromFile:nil];
    }
    @catch (NSException *exception) {
        AODLOG_ERROR(@"%@",[exception description]);
        //[self.delegate onConfigFailedToLoad:0];
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
