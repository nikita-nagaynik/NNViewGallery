//
//  NNZoomContainer.h
//
//  Created by Nikita Nagaynik on 22/10/14.
//

@interface NNZoomContainer : UIScrollView <UIScrollViewDelegate>

@property (strong, nonatomic, readonly) UIView *view;
@property (assign, nonatomic) CGFloat doubleTapScale;

- (instancetype)initWithView:(UIView *)view;
- (instancetype)initWithView:(UIView *)view scale:(CGFloat)scale;

- (void)updateLayout;
- (void)resetZoom;

- (void)takeIntoOneTapRecognizer:(UIGestureRecognizer *)recognizer;

@end
