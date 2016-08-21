#import <Preferences/Preferences.h>

#import "../include.h"
#import "MHDPreferences.h"

@interface MinimalHUDListController : PSListController

@property (nonatomic, strong) MHDPreferences *preferences;

@end

@implementation MinimalHUDListController

- (MHDPreferences *)preferences
{
	if (!_preferences)
	{
		NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
		_preferences = [[MHDPreferences alloc] initWithSettings:settings];
	}
	return _preferences;
}

- (id)specifiers {
	NSMutableArray *specs = [[NSMutableArray alloc] init];

	// Enable button
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain]];

	// Color settings
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode" target:self] retain]];
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_theme" target:self] retain]];
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_custom" target:self] retain]];

	// Location settings
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode" target:self] retain]];
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_preset" target:self] retain]];
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_custom" target:self] retain]];

	_specifiers = specs;

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value forSpecifier:(PSSpecifier*)specifier {
	[self.preferences updateValue:value forKey:specifier.properties[@"key"]];
	[self.preferences.dictionaryRepresentation writeToFile:PREFERENCES_PATH atomically:NO];

	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

@end

