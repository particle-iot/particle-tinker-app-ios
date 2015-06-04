#import <UIKit/UIKit.h>
#import "DevicePin.h"
#import "PinValueView.h"

// TODO: move to utils (in SparkSetup lib?)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@class PinView;

@protocol PinViewDelegate <NSObject>

- (void)pinViewTapped:(PinView *)pinView;
- (void)pinViewHeld:(PinView *)pinView;

@end

@interface PinView : UIView

@property (weak) id<PinViewDelegate> delegate;


-initWithPin:(DevicePin *)pin;
@property (nonatomic, strong) DevicePin *pin;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) PinValueView* valueView;

- (void)refresh;

-(void)beginUpdating;
-(void)endUpdating;


@end
