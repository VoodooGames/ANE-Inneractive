#import "FlashRuntimeExtensions.h"
#import "InneractiveAd.h"


@interface Inneractive : NSObject <InneractiveAdDelegate>

+ (Inneractive *)sharedInstance;

@end
