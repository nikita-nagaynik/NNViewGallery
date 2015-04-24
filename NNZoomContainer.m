//
//  NNZoomContainer.m
//
//  Created by Nikita Nagaynik on 22/10/14.
//

#import "NNZoomContainer.h"
#import "UIView+FrameEditing.h"

@interface NNZoomContainer ()

@property (assign, nonatomic) CGFloat scale;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;

@end


@implementation NNZoomContainer

- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init]) {
        _view = view;
        [self addSubview:self.view];
        [self initialize];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view scale:(CGFloat)scale
{
    if (self = [self initWithView:view]) {
        self.scale = scale;
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.doubleTapScale = 1.5;
    
    self.delegate = self;
    
    
    if (self.scale > 1.0) {
        [self setupDoubleTapRecognizer];
        [self setupZoom];
    }
    
    [self updateLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateLayout
{
    self.view.frame = self.bounds;
    self.contentSize = self.frame.size;
}

- (void)resetZoom
{
    [self setupZoom];
}

- (void)setupZoom
{
    if (self.scale > 1.0) {
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = self.scale;
        self.zoomScale = 1.0;
    }
}

- (void)orientationDidChange:(NSNotification *)note
{
    [self updateLayout];
    [self resetZoom];
}

- (void)takeIntoOneTapRecognizer:(UIGestureRecognizer *)recognizer
{
    if (self.doubleTapRecognizer) {
        [recognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.view;
}

- (void)setupDoubleTapRecognizer
{
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(doubleTapped:)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:self.doubleTapRecognizer];
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.view];
    CGFloat newZoomScale = self.zoomScale * self.doubleTapScale;
    
    newZoomScale = MIN(newZoomScale, self.maximumZoomScale);
    CGSize scrollViewSize = self.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - w * 0.5;
    CGFloat y = pointInView.y - h * 0.5;
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self zoomToRect:rectToZoomTo animated:YES];
}

@end
