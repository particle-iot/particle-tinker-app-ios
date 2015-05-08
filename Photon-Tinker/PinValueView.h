#import <UIKit/UIKit.h>
#import "SPKCorePin.h"

#define PIN_ANALOGREAD_MAX_VALUE     4095.0f
#define PIN_ANALOGWRITE_MAX_VALUE    255.0f


@interface PinValueView : UIView

-(instancetype)initWithPin:(SPKCorePin *)pin;
@property (nonatomic, strong) SPKCorePin *pin;
@property (nonatomic) BOOL active;

-(void)refresh;
-(void)showSlider;

@end
