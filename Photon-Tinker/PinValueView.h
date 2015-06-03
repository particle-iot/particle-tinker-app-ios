#import <UIKit/UIKit.h>
#import "DevicePin.h"

#define PIN_ANALOGREAD_MAX_VALUE     4095.0f
#define PIN_ANALOGWRITE_MAX_VALUE    255.0f

@class PinValueView;

@protocol PinValueViewDelegate <NSObject>

-(void)pinValueView:(PinValueView *)sender sliderMoved:(float)newValue touchUp:(BOOL)touchUp;

@end

@interface PinValueView : UIView

-(instancetype)initWithPin:(DevicePin *)pin;
@property (nonatomic, strong) DevicePin *pin;
@property (nonatomic) BOOL active;
@property (nonatomic, weak) id <PinValueViewDelegate> delegate;
@property (nonatomic) BOOL sliderShowing;

-(void)refresh;
-(void)showSlider;
-(void)hideSlider;


@end
