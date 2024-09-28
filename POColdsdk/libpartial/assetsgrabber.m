//
//  libpartial.m
//  POColdsdk
//
//  Created by LL on 9/4/24.
//

#import <Foundation/Foundation.h>
#import "partial.h"
#import "assetsgrabber.h"

NSString* getApplicationSupportDirectory() {
    NSArray<NSURL *> *paths = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *appSupportDir = paths.firstObject;
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSURL *appDirectory = [appSupportDir URLByAppendingPathComponent:bundleIdentifier];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectory.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:appDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Failed to create Application Support directory: %s\n", error.localizedDescription.UTF8String);
        }
    }
    
    return appDirectory.path;
}

NSString* getAssetBackupsDirectory() {
    NSString* appSupportPath = getApplicationSupportDirectory();
    NSString* assetBackupsPath = [appSupportPath stringByAppendingPathComponent:@"assetbackups"];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:assetBackupsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:assetBackupsPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Failed to create assetbackups directory: %s\n", error.localizedDescription.UTF8String);
        }
    }
    
    return assetBackupsPath;
}

// Code skidded from libgrabkernel2 but changed.
bool grabAssetsCar(NSString* zipURL, NSString* appName) {
    NSError *error = nil;
//    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
//    NSString* appSupportPath = getApplicationSupportDirectory();
    NSString* bundlePath = getAssetBackupsDirectory();
    NSString *outPath = [NSString stringWithFormat:@"%@/%@_ORIGINAL_ASSETS.car", bundlePath, appName];
    Partial *zip = [Partial partialZipWithURL:[NSURL URLWithString:zipURL] error:&error];
    if (!zip) {
        NSLog(@"Failed to open zip file! %s\n", error.localizedDescription.UTF8String);
        return false;
    }
    NSData *assetsData = [zip getFileForPath:[NSString stringWithFormat:@"Payload/%@/Assets.car", appName] error:&error];
    NSLog(@"outPath: %@", outPath);
    if (![assetsData writeToFile:outPath options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Failed to write assets to %s! %s\n", outPath.UTF8String, error.localizedDescription.UTF8String);
        return false;
    }
    return true;
}

bool grabInfoPlist(NSString* zipURL, NSString* appName) {
    NSError *error = nil;
//    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* bundlePath = getAssetBackupsDirectory();
    NSString *outPath = [NSString stringWithFormat:@"%@/%@_ORIGINAL_INFO.plist", bundlePath, appName];
    Partial *zip = [Partial partialZipWithURL:[NSURL URLWithString:zipURL] error:&error];
    if (!zip) {
        NSLog(@"Failed to open zip file! %s\n", error.localizedDescription.UTF8String);
        return false;
    }
    NSData *assetsData = [zip getFileForPath:[NSString stringWithFormat:@"Payload/%@/Info.plist", appName] error:&error];
    NSLog(@"Writing backup to: %@", outPath);
    if (![assetsData writeToFile:outPath options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Failed to write info.plist to %s! %s\n", outPath.UTF8String, error.localizedDescription.UTF8String);
        return false;
    }
    return true;
}
