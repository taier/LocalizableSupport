//
//  LocalizationManager.m
//  LocalizableSupport
//
//  Created by Deniss Kaibagarovs on 2/11/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

#import "LocalizationManager.h"

#define LAST_SELECTED_LANGUAGE_KEY @"LAST_SELECTED_LANGUAGE_KEY"
#define DEFUALT_LANGUAGE_NAME @"en"

@interface LocalizationManager ()

@property (nonatomic, retain) NSDictionary *languagesDict;
@property (nonatomic, copy) NSString *language;

@end

@implementation LocalizationManager

#pragma mark Live Cycle

+ (LocalizationManager *)sharedInstance {
    
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_updateLanguagesIfNeeded];
        self.language = [self p_checkIfCanTranslateToLanguage:self.lastSelectedLanguage];
    }
    return self;
}

#pragma mark Public Methods

+ (NSString *)translationForKey:(NSString *)key {
    return [[LocalizationManager sharedInstance] p_translationForKey:key];
}

+ (void)updateLanguage:(NSString *)languageName {
    // Skip new language if it the same as the old one
    if ([languageName isEqualToString:[LocalizationManager sharedInstance].language]) return;
    
    NSString *newLanguage = [[LocalizationManager sharedInstance] p_checkIfCanTranslateToLanguage:languageName];
    // Save last selected language
    [LocalizationManager sharedInstance].language = newLanguage;
    [[NSUserDefaults standardUserDefaults] setObject:newLanguage forKey:LAST_SELECTED_LANGUAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Notify application
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:LocalizationManagerLanguageDidChangeNotification object:nil]];
}

#pragma mark Private Methods

- (NSString *)p_translationForKey:(NSString *)key {
    return [self p_translationForKey:key language:self.language];
}

- (NSString *)p_translationForKey:(NSString *)key language:(NSString *)language {
    NSDictionary *languageDict = self.languagesDict[language];
    NSString *translatedString = languageDict[key];
#warning UNCOMMENT TO CHECK DEFUALT LOCALIZABLE.STRING
//    translatedString = nil;
    // If don't have translation in JSON, try to get it from Localizable.string
    return (translatedString) ? translatedString : NSLocalizedString(key, nil);
}

- (void)p_updateLanguagesIfNeeded {
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [path firstObject];
    NSString *localizationJSONPath = [libraryDirectory stringByAppendingPathComponent:@"remote_languages.json"];
    
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/taier/LocalizableSupport/master/remote_languages.json"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    
    // Get the data
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if (![data length]) return;
    // Save to Library Folder
    [data writeToFile:localizationJSONPath atomically:YES];
    // Fill languages from the JSON data
    NSError *error;
    self.languagesDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

- (NSString *)p_checkIfCanTranslateToLanguage:(NSString *)language {
    
    //  Check for supported language
    if ([self.supportedLanguages indexOfObject:language] == NSNotFound) {
        language = nil;
    }
#warning UNCOMMENT TO CHECK PREFFERED LANGUAGE ORDER
//     language = nil;
    // Get language by order preffered
    if (!language) {
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        language = [preferredLanguages firstObjectCommonWithArray:self.supportedLanguages];
    }
    
    // If don't have that language - return default one (last selected, or english by default)
    if (language == nil) {
        NSString *preferredLanguage = [self lastSelectedLanguage];
        language = (preferredLanguage) ? preferredLanguage : DEFUALT_LANGUAGE_NAME;
    }
    
    return language;
}

#pragma mark Dynamic variables

- (NSArray *)supportedLanguages {
    return [self.languagesDict allKeys];
}

- (NSString *)lastSelectedLanguage {
   return [[NSUserDefaults standardUserDefaults] stringForKey:LAST_SELECTED_LANGUAGE_KEY];
}

@end
