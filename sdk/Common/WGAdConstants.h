//
//  WGAdConstants.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#ifndef WGAdConstants_h
#define WGAdConstants_h

#define DEBUG_ERROR         DEBUG == 0 ? 0 : 0
#define DEBUG_FULL_BANNER   DEBUG == 0 ? 0 : 1
#define DEBUG_SMALL_BANNER  DEBUG == 0 ? 0 : 1
#define DEBUG_VIDEO         DEBUG == 0 ? 0 : 1
#define DEBUG_DEBUG         DEBUG == 0 ? 0 : 1
#define DEBUG_INFO          0 // AODLOG()

#define PRECACHE_ALLOWED    0

#define SERVER_TIMEOUT          20
#define LOADING_TIMEOUT_MS      60000.0 // 60 sec
#define CACHE_REFRESH_MS        240000.0 // 4 min
#define CACHE_TIMEOUT_MS        240000.0 // 4 min
#define CACHE_REFRESH_NEVER     -1
#define FAILED_REQUEST_S         5
#define FAILED_REQUEST_MS       5000.0
#define MAX_FAILED_REQUEST_MS   100.0 * 1000.0

// Banner
#define DEFAULT_BANNER_REFRESH_INTERVAL    30
#define BANNER_TIMEOUT_INTERVAL            10

// Timers (sec.)
#define INTERSTITIAL_PRECACHE_TIMEOUT_FOR_TIMER       2
#define RESET_FL_COUNTER_PRECACHE_TIMEOUT_FOR_TIMER   120 // 2 min
#define RESET_FL_COUNTER_BANNER_TIMEOUT_FOR_TIMER     120 // 2 min
#define CACHE_REFRESH_TIMEOUT_FOR_TIMER               900 // 15 min
#define INTERSTITIAL_TIMEOUT_INTERVAL                 10
#define VIDEO_TIMEOUT_INTERVAL                        20
#define PRELOADER_TIMEOUT_FOR_TIMER                   3
#define PRELOADER_TIMEOUT_FOR_TIMER_VIDEO             10
#define SERVER_NOT_RESPONDING_TIMEOUT                 60

// Timeouts for ad which loaded
#define CONFIG_STORE_TIMEOUT                          12 // in hours
#define ANTICLICKER_TIMEOUT                           24 // in hours

// String keys
#define PKEY_VIDEO_ADMOB_AGGR       @"ADMOB_VIDEO_AGGR"
#define PKEY_INTERS_ADMOB_AGGR      @"ADMOB_INTERS_AGGR"
#define PKEY_GAME_ADCONFIG          @"GAME_ADS_CONFIG"
#define PKEY_AUTOCACHE              @"ADS_MANAGER_AUTOCACHE"

// Remote Config keys
#define REM_CFG_ADCONFIG            @"%@_ad_config"
#define REM_CFG_ADMOB_V_AGGR        @"%@_v_admob_aggr"
#define REM_CFG_ADMOB_I_AGGR        @"%@_i_admob_aggr"

#endif /* WGAdConstants_h */
