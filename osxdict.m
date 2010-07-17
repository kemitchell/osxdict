#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>

NSUserDefaults *userDefaults;
NSMutableDictionary *dictionaryPrefs;

NSString * const DefaultsIdentifier = @"com.apple.DictionaryServices";
NSString * const ActiveDictionariesKey = @"DefaultsIdentifier";

void SetActiveDictionaries(NSArray *dictionaries) {
	[dictionaryPrefs setObject:dictionaries forKey:ActiveDictionariesKey];
	[userDefaults setPersistentDomain:dictionaryPrefs forName:DefaultsIdentifier];
}

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Shorthands for dictionaries shipped with OS 10.6 Snow Leopard
	NSArray *keys = [NSArray arrayWithObjects:
		@"apple",
		@"thesaurus",
		@"dictionary",
		@"daijisen",
		@"progressive",
		@"ruigo",
		nil];
	NSArray *objects = [NSArray arrayWithObjects:
		@"/Library/Dictionaries/Apple Dictionary.dictionary",
		@"/Library/Dictionaries/New Oxford American Dictionary.dictionary",
		@"/Library/Dictionaries/Oxford American Writer's Thesaurus.dictionary",
		@"/Library/Dictionaries/Shogakukan Daijisen.dictionary",
		@"/Library/Dictionaries/Shogakukan Progressive English-Japanese Japanese-English Dictionary.dictionary",
		@"/Library/Dictionaries/Shogakukan Ruigo Reikai Jiten.dictionary",
		nil];
	NSDictionary *shorthands = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	if(argc != 3) {
		printf("Usage: osxdict <.dictionary path or shorthand> <word>\n\nDefined Shorthands:\n");
		for(id key in shorthands) {
			printf("%-15.15s", [key UTF8String]);
			printf("   %s\n", [[shorthands objectForKey:key] UTF8String]);
		}
	} else {
		userDefaults = [NSUserDefaults standardUserDefaults];
		dictionaryPrefs = [[userDefaults persistentDomainForName:DefaultsIdentifier] mutableCopy];
		
		// Cache the original active dictionaries
		NSArray *activeDictionaries = [dictionaryPrefs objectForKey:ActiveDictionariesKey];
		
		// Set the specified dictionary as the only active dictionary
		NSString *dictionaryArgument = [NSString stringWithUTF8String: argv[1]];
		NSString *shortHand = [shorthands objectForKey:dictionaryArgument];
		NSString *dictionaryPath;
		if(shortHand == nil) {
			dictionaryPath = dictionaryArgument;
		} else {
			dictionaryPath = shortHand;
		}
		SetActiveDictionaries([NSArray arrayWithObject:dictionaryPath]);
		
		// Get the definition
		NSString *word = [NSString stringWithUTF8String:argv[2]];
		puts([(NSString *)DCSCopyTextDefinition(NULL, (CFStringRef)word, CFRangeMake(0, [word length])) UTF8String]);
		
		// Restore the cached active dictionaries
		SetActiveDictionaries(activeDictionaries);
	}
	
}