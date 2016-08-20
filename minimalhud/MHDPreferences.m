#import "MHDPreferences.h"

#define NOT_FOUND -1

@interface MHDPreferences ()

@property (nonatomic, readwrite) BOOL enabled;
@property (nonatomic, readwrite) MHDColorMode colorMode;
@property (nonatomic, readwrite) MHDColorTheme colorTheme;
@property (nonatomic, strong) UIColor *startingColor;
@property (nonatomic, strong) UIColor *endingColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, readwrite) MHDLocationMode locationMode;
@property (nonatomic, readwrite) MHDLocationPreset locationPreset;
@property (nonatomic, readwrite) MHDLocationOrientation locationOrientation;
@property (nonatomic, readwrite) CGFloat locationX;
@property (nonatomic, readwrite) CGFloat locationY;

@end

@implementation MHDPreferences

- (instancetype)initWithSettings:(NSDictionary *)settings
{
	self = [super init];
	if (self)
	{
		NSNumber *e = settings[@"enabled"];
		self.enabled = e ? e.boolValue : YES;

		NSNumber *cM = settings[@"colorMode"];
		self.colorMode = cM ? cM.unsignedIntegerValue : MHDColorModeTheme;

		if (self.colorMode == MHDColorModeTheme)
		{
			NSNumber *cT = settings[@"colorTheme"];
			self.colorTheme = cT ? cT.unsignedIntegerValue : MHDColorThemeWarm;
		}
		else if (self.colorMode == MHDColorModeCustom)
		{
			NSString *sC = settings[@"startingColor"];
			UIColor *sColor = nil;
			if (sC)
			{
				sColor = [self.class colorFromString:sC];
			}
			self.startingColor = sColor ? : [UIColor whiteColor];

			NSString *eC = settings[@"endingColor"];
			UIColor *eColor = nil;
			if (eC)
			{
				eColor = [self.class colorFromString:eC];
			}
			self.endingColor = eColor ? : [UIColor whiteColor];

			NSString *bC = settings[@"backgroundColor"];
			UIColor *bColor = nil;
			if (bC)
			{
				bColor = [self.class colorFromString:bC];
			}
			self.backgroundColor = bColor ? : [UIColor blackColor];
		}

		NSNumber *lM = settings[@"locationMode"];
		self.locationMode = lM ? lM.unsignedIntegerValue : MHDLocationModePreset;

		if (self.locationMode == MHDLocationModePreset)
		{
			NSNumber *lP = settings[@"locationPreset"];
			self.locationPreset = lP ? lP.unsignedIntegerValue : MHDLocationPresetTop;
		}
		else if (self.locationMode == MHDLocationModeCustom)
		{
			NSNumber *lO = settings[@"locationOrientation"];
			self.locationOrientation = lO ? lO.unsignedIntegerValue : MHDLocationOrientationHorizontal;

			NSString *lX = settings[@"locationX"];
			self.locationX = lX ? [self.class cgFloatFromString:lX] : 0.0;

			NSString *lY = settings[@"locationY"];
			self.locationY = lY ? [self.class cgFloatFromString:lY] : 0.0;
		}
	}
	return self;
}

+ (UIColor *)colorFromString:(NSString *)string
{
	NSDictionary *colors = @{
		@"red" : [UIColor redColor],
		@"orange" : [UIColor orangeColor],
		@"yellow" : [UIColor yellowColor],
		@"green" : [UIColor greenColor],
		@"blue" : [UIColor blueColor],
		@"purple" : [UIColor purpleColor],
		@"black" : [UIColor blackColor],
		@"white" : [UIColor whiteColor]
	};

	NSString *finalStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	UIColor *color = colors[finalStr.lowercaseString];
	if (color)
	{
		NSLog(@"found color %@", finalStr);
		return color;
	}

	return [self colorWithHexString:finalStr];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];          
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];                      
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];                      
            break;
        default:
        	return nil;
    }

    NSLog(@"%@ %@ %@ %@", @(red), @(green), @(blue), @(alpha));

    if (red == NOT_FOUND || green == NOT_FOUND || blue == NOT_FOUND)
    {
    	return nil;
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned int hexComponent;
    BOOL success = [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    if (!success)
    {
    	return NOT_FOUND;
    }
    return hexComponent / 255.;
}

+ (CGFloat)cgFloatFromString:(NSString *)string
{
    double doubleValue;
    BOOL success = [[NSScanner scannerWithString:string] scanDouble:&doubleValue];
    if (!success)
    {
    	return 0.;
    }
    return (CGFloat)doubleValue;
}

@end