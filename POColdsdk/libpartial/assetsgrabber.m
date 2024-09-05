//
//  libpartial.m
//  POColdsdk
//
//  Created by LL on 9/4/24.
//

#import <Foundation/Foundation.h>
#import "partial.h"
#import "assetsgrabber.h"
// Code skidded from libgrabkernel2 but changed.
bool grabAssetsCar(NSString* zipURL, NSString* appName) {
    NSError *error = nil;
    Partial *zip = [Partial partialZipWithURL:[NSURL URLWithString:zipURL] error:&error];
    if (!zip) {
        NSLog(@"Failed to open zip file! %s\n", error.localizedDescription.UTF8String);
        return false;
    }
    NSData *assetsData = [zip getFileForPath:[NSString stringWithFormat:@"Payload/%@.app/Assets.car", appName] error:&error];
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *outPath = [NSString stringWithFormat:@"%@/assetbackups/%@_ORIGINAL_ASSETS.car", bundlePath, appName];
    NSLog(@"outPath: %@", outPath);
    if (![assetsData writeToFile:outPath options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Failed to write assets to %s! %s\n", outPath.UTF8String, error.localizedDescription.UTF8String);
        return false;
    }
    return true;
}
