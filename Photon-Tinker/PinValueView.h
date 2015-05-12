#import <UIKit/UIKit.h>
#import "SPKCorePin.h"

#define PIN_ANALOGREAD_MAX_VALUE     4095.0f
#define PIN_ANALOGWRITE_MAX_VALUE    255.0f

#define PinValueViewWidth            160
#define PinValueViewHeight           44

@class PinValueView;

@protocol PinValueViewDelegate <NSObject>

-(void)pinValueView:(PinValueView *)sender sliderMoved:(float)newValue touchUp:(BOOL)touchUp;

@end

@interface PinValueView : UIView

-(instancetype)initWithPin:(SPKCorePin *)pin;
@property (nonatomic, strong) SPKCorePin *pin;
@property (nonatomic) BOOL active;
@property (nonatomic, weak) id <PinValueViewDelegate> delegate;
@property (nonatomic) BOOL sliderShowing;

-(void)refresh;
-(void)showSlider;
-(void)hideSlider;


@end
