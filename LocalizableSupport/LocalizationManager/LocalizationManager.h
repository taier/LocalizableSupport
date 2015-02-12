//
//  LocalizationManager.h
//  LocalizableSupport
//
//  Created by Deniss Kaibagarovs on 2/11/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LocalizationManagerLanguageDidChangeNotification @"LocalizationManagerLanguageDidChangeNotification"

@interface LocalizationManager : NSObject

+ (LocalizationManager *)sharedInstance;
+ (NSString *)translationForKey:(NSString *)key;
+ (void)updateLanguage:(NSString *)languageName;

@end
