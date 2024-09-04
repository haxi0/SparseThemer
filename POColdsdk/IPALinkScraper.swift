//
//  IPALinkScraper.swift
//  POColdsdk
//
//  Created by LL on 9/4/24.
//
// Everything here is taken from ipatool.
import Foundation

// https://github.com/majd/ipatool/blob/63ee6fc6a42a89d51c9caac632cefd65218825ab/pkg/appstore/constants.go#L21

struct iTunesConstants {
    var FailureTypeInvalidCredentials     = "-5000"
    var FailureTypePasswordTokenExpired   = "2034"
    var FailureTypeLicenseNotFound        = "9610"
    var FailureTypeTemporarilyUnavailable = "2059"
    var CustomerMessageBadLogin             = "MZFinance.BadLogin.Configurator_message"
    var CustomerMessageSubscriptionRequired = "Subscription Required"
    var iTunesAPIDomain     = "itunes.apple.com"
    var iTunesAPIPathSearch = "/search"
    var iTunesAPIPathLookup = "/lookup"
    var PrivateAppStoreAPIDomainPrefixWithoutAuthCode = "p25"
    var PrivateAppStoreAPIDomainPrefixWithAuthCode    = "p71"
    var PrivateAppStoreAPIDomain                      = "buy.itunes.apple.com"
    var PrivateAppStoreAPIPathAuthenticate            = "/WebObjects/MZFinance.woa/wa/authenticate"
    var PrivateAppStoreAPIPathPurchase                = "/WebObjects/MZBuy.woa/wa/buyProduct"
    var PrivateAppStoreAPIPathDownload                = "/WebObjects/MZFinance.woa/wa/volumeStoreDownloadProduct"
    var HTTPHeaderStoreFront = "X-Set-Apple-Store-Front"
    var PricingParameterAppStore    = "STDQ"
    var PricingParameterAppleArcade = "GAME"
}

// Idea: We have a list of all our user apps. Get their bundle id, then search up their download links.
// After that, use pzb to get their assets.car.
// Store the original as hashmap<bundleid, <bundleid>_original_assets.car>
// Make a new copy with hashmap<bundleid, <bundleid>_TWEAKED_assets.car>
