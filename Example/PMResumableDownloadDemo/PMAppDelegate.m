//
//  PMAppDelegate.m
//  PMResumableDownloadDemo
//
//  Created by Pierre-Marc Airoldi on 2014-04-29.
//  Copyright (c) 2014 Pierre-Marc Airoldi. All rights reserved.
//

#import "PMAppDelegate.h"
#import <PMResumableDownloader/PMResumableDownloader.h>

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    //demo
    
    NSArray *URLs = @[@"http://images.gadmin.st.s3.amazonaws.com/n49487/images/buehne/image2.jpeg",
                      @"http://www.designsnext.com/wp-content/uploads/2014/04/nature-wallpapers-16.jpg",
                      @"http://finalmile.in/behaviourarchitecture/wp-content/uploads/2013/04/forces-of-nature-wallpaper.jpg",
                      @"http://images2.fanpop.com/images/photos/4800000/Beauty-of-nature-random-4884759-1280-800.jpg",
                      @"http://3.bp.blogspot.com/-0K132QvQ1D8/UVknJpBvxbI/AAAAAAAAGMI/ZtFyefyHJac/s1600/Beautiful-Nature-+wallpaper.jpg",
                      @"http://datastore04.rediff.com/h1500-w1500/thumb/5A5A5B5B4F5C1E5255605568365E655A63672A606D6C/0upnd2vwarhp3y9i.D.0.Copy-of-Nature-Wallpapers-9.jpg",
                      ];
    
    for (NSString *url in URLs) {
        
        [[PMResumableDownloader sharedDownloadHandler] addItemToDownloadFrom:[NSURL URLWithString:url] withCompletionBlock:^{
            
            NSLog(@"%@ end", url);
            
        } startImmediately:YES];
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
