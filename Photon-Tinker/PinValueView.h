#import <UIKit/UIKit.h>
#import "SPKCorePin.h"


@interface PinValueView : UIView

-(instancetype)initWithPin:(SPKCorePin *)pin;
@property (nonatomic, strong) SPKCorePin *pin;
@property (nonatomic) BOOL active;

- (void)refresh;

@end
