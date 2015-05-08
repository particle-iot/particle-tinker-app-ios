#import <UIKit/UIKit.h>
#import "SPKCorePin.h"
#import "PinValueView.h"


@class PinView;

@protocol PinViewDelegate <NSObject>

- (void)pinViewTapped:(PinView *)pinView;
//- (void)pinViewAdjusted:(PinView *)pinView newValue:(NSUInteger)newValue;
- (void)pinViewHeld:(PinView *)pinView;

@end

@interface PinView : UIView

@property (weak) id<PinViewDelegate> delegate;


-initWithPin:(SPKCorePin *)pin;
@property (nonatomic, strong) SPKCorePin *pin;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) PinValueView* valueView;

- (void)refresh;
//- (void)hideDetails;
//- (void)showDetails;
//- (void)noslider;
//- (void)slider;

@end
