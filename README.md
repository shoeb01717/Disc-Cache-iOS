Disc-Cache-iOS
==============

Store the cache for NSURLRequest in disc not system memory. So after you close the app if you reopen the cache will still be there.


you can also return cache from main bundle. Create and organise a folder with server images (which you want to be returned from mainbundle perticularly when you load an webview) exactly it is organised in server (Ex: Example_Project_server/assets/img/button.png)

Drag this example_project_server folder you created to Xcode file lists. check the option "create folder reference for any added folders" and "Copy items into destination group's folder(if needed)"

if "request.URL.relativePath" from line 102 of StorageCache.m matches the path of any of your files, the cache will be returned from that file..

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


