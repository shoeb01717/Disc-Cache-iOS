Disc-Cache-iOS
==============


write this to initalize your custom cache (best to write this on AppDelegate.m) 

	#import "StorageCache.h"


------------------------------------------------------------------

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(
                                        NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* diskCachePath =
    [NSString stringWithFormat:
     @"%@/%@", documentsDirectory, @"myCache"];
    
    StorageCache* cacheMngr = [[StorageCache alloc]
                          initWithMemoryCapacity:20*1024*1024
                          diskCapacity:100*1024*1024 diskPath:diskCachePath];
    [NSURLCache setSharedURLCache:cacheMngr];

    --------------------------------------------------------------


