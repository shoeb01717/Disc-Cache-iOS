
//
//  StorageCache.m
//  Chaching-Example
//
//  Created by Shoeb on 9/5/13.
//  Copyright (c) 2013 Shoeb Amin. All rights reserved.


#import "StorageCache.h"



@implementation StorageCache

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    
	NSArray *paths =
    NSSearchPathForDirectoriesInDomains(
                                        NSCachesDirectory, NSUserDomainMask, YES);
    

	NSLog(@"==CACHE REQUEST %@", request);
    
	NSString *cacheDirectory = [paths objectAtIndex:0];
	NSArray* tokens = [request.URL.relativePath componentsSeparatedByString:@"/"];
	if (tokens==nil) {
        

		NSLog(@"no slash. ignoring cache for %@", request);

		return nil;
	}
	NSString* pathWithoutRessourceName=@"";
	for (int i=0; i<[tokens count]-1; i++) {
		pathWithoutRessourceName =
        [pathWithoutRessourceName stringByAppendingString:
         [NSString stringWithFormat:
          @"%@%@", [tokens objectAtIndex:i], @"/"]];
	}
    
	NSString* absolutePath =
    [NSString stringWithFormat:
     @"%@%@", cacheDirectory, pathWithoutRessourceName];

    
	NSString* absolutePathWithRessourceName =
    [NSString stringWithFormat:
     @"%@%@", cacheDirectory, request.URL.relativePath];

    
	NSString* ressourceName = [absolutePathWithRessourceName
                               stringByReplacingOccurrencesOfString:absolutePath withString:@""];

    
	NSCachedURLResponse* cacheResponse = nil;
    
    if ([ressourceName rangeOfString:@"opening"].location!=NSNotFound) {
        return nil;
    }
    
	//caching file ext
	if ([ressourceName rangeOfString:@".png"].location!=NSNotFound ||
		[ressourceName rangeOfString:@".gif"].location!=NSNotFound ||
		[ressourceName rangeOfString:@".js"].location!=NSNotFound ||
		[ressourceName rangeOfString:@".css"].location!=NSNotFound ||
		[ressourceName rangeOfString:@".jpg"].location!=NSNotFound
        ){
        
        NSString* storagePath =
        [NSString stringWithFormat:
         @"%@/myCache%@", cacheDirectory, request.URL.relativePath];

        

        NSData* content;
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:storagePath]
            ) {

            
            NSLog(@"storagePath =%@",storagePath);
            NSLog(@"==CACHE FOUND for %@", request.URL.relativePath);

            content = [NSData dataWithContentsOfFile:storagePath];
            
            NSURLResponse* response =
            [[NSURLResponse alloc]
             initWithURL:request.URL MIMEType:
             @"" expectedContentLength:[content length]
             textEncodingName:nil];
            
            cacheResponse = [[NSCachedURLResponse alloc]
                             initWithResponse:response data:content]  ;
            
        
            
        } else {
            NSLog(@"%@",request.URL.relativePath);
            
            NSString *fileName = request.URL.relativePath;
            
            
            NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
            
            NSLog(@"filePath %@",filePath);
            
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                
                NSArray *array = [ressourceName componentsSeparatedByString:@"."];
                NSString *myme;
                if ([array count]>0) {
                    myme = [array objectAtIndex:[array count]-1];
                }
                NSData *data;
                                
                    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                
                
                
                
                NSURLResponse* response =
                [[NSURLResponse alloc]
                 initWithURL:request.URL MIMEType:
                 @"" expectedContentLength:[data length]
                 textEncodingName:nil];
                
                cacheResponse = [[NSCachedURLResponse alloc]
                                  initWithResponse:response data:data]  ;//autorelease by Shoeb

                
                NSLog(@"mainBundle-----------------------------------");

          
                
            } else {
                //trick here : if no cache, populate it asynchronously and return nil
                [NSThread detachNewThreadSelector:
                 @selector(populateCacheFor:) toTarget:self withObject:request];
            }
            
            
        }
        
	} else {
        
        
	}
    
	return cacheResponse;
}


-(void)populateCacheFor:(NSURLRequest*)request {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                             NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSArray* tokens = [request.URL.relativePath componentsSeparatedByString:@"/"];
        
        NSString* pathWithoutRessourceName=@"";
        
        for (int i=0; i<[tokens count]-1; i++) {
            pathWithoutRessourceName =
            [pathWithoutRessourceName
             stringByAppendingString:[
                                      NSString stringWithFormat:
                                      @"%@%@", [tokens objectAtIndex:i], @"/"]];
        }
        
        NSString* absolutePath = [NSString stringWithFormat:
                                  @"%@/myCache%@", documentsDirectory, pathWithoutRessourceName];
        //    NSLog(@"absolutePath =%@",absolutePath);
        
        NSString* storagePath = [NSString stringWithFormat:
                                 @"%@/myCache%@", documentsDirectory, request.URL.relativePath];
        
        
        NSData* content;
        NSError* error = nil;
        
        
        //Synchronus call
        if(([[[UIDevice currentDevice] systemVersion] compare:@"5.1" options:NSNumericSearch] != NSOrderedAscending)){
            [request.URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
        }
        //[request.URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];//Shoeb
        content = [NSData dataWithContentsOfURL:request.URL options:1 error:&error];
        
        if (error!=nil) {
            
            
        } else {
            
            //the store is invoked automatically.
            [[NSFileManager defaultManager]
             createDirectoryAtPath:absolutePath
             withIntermediateDirectories:YES attributes:nil error:&error];
            
            BOOL ok = [content writeToFile:storagePath atomically:YES];
            
            if (ok == YES){
                
                
            }else{
                
                
                NSLog(@"!!Caching fail %@", storagePath );
                
                NSString *nsstr = [[NSString alloc] initWithFormat:
                                   @"caching fail%c%@",
                                   0x0a,
                                   storagePath]
                ;
                
                UIAlertView* alert=[[UIAlertView alloc] 
                                    initWithTitle:nil
                                    message:nsstr
                                    delegate:nil 
                                    cancelButtonTitle:@"OK" otherButtonTitles:nil] ;
                [alert show];
            }
            
        }
    }

    
}

@end


