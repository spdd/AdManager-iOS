//
//  WGConfigLoader.h
//  WordGames
//
//  Created by Dmitry B on 01.03.16.
//
//

#import <Foundation/Foundation.h>

@protocol WGConfigLoaderDelegate <NSObject>

- (void) onConfigFailedToLoad:(int)errorCode;
- (void) onConfigLoaded:(NSDictionary*)config;

@end

@interface WGConfigLoader : NSObject

- (void) fetch;
- (void)runTask;
- (void)runTaskWithConfig:(NSString*)config;
- (NSString*) getConfigKey;

@property (nonatomic, weak) id<WGConfigLoaderDelegate> delegate;

@end
