//
//  NNViewGallery.h
//
//  Created by Nikita Nagaynik on 22/10/14.
//

@interface NNViewGallery : UIView

@property (strong, nonatomic, readonly) UIScrollView *scrollView;

@property (weak, nonatomic) UIPageControl *dependedPageControl;

@property (assign, nonatomic) CGFloat doubleTapScale;
@property (assign, nonatomic) CGFloat maxScale;
@property (assign, nonatomic) BOOL zoomEnable;

@property (assign, nonatomic) NSInteger numberOfItems;
@property (assign, nonatomic) NSInteger currentItem;
@property (assign, nonatomic) NSInteger itemBufferSize;

@property (strong, nonatomic) UIView *(^itemAtIndex)(NSUInteger index);
@property (strong, nonatomic) void(^itemTapped)(NSUInteger index);
@property (strong, nonatomic) void(^currentItemChanged)(NSUInteger index);
@property (strong, nonatomic) void(^strongItemChanged)(NSUInteger index);

- (void)initialize;
- (void)populate;

@end