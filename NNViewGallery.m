//
//  NNViewGallery.m
//
//  Created by Nikita Nagaynik on 22/10/14.
//

#import "NNViewGallery.h"

#import "UIView+FrameEditing.h"
#import "NAZoomContainer.h"
#import "NSArray+NAExtensions.h"

@interface NNViewGallery () <UIScrollViewDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *oneTapRecognizer;
@property (strong, nonatomic) NSMutableDictionary *placedItems;

@property (assign, nonatomic) NSInteger strongCurrentItem;

@end

@implementation NNViewGallery

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setCurrentItem:(NSInteger)currentItem
{
    _currentItem = currentItem;
    _strongCurrentItem = currentItem;
}

- (void)initialize
{    
    self.zoomEnable = YES;
    self.maxScale = 3.0;
    self.doubleTapScale = 1.5;
    self.itemBufferSize = 7;
    
    self.placedItems = [NSMutableDictionary dictionaryWithCapacity:self.itemBufferSize];
    
    [self setupMainScrollView];
    
    self.oneTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self addGestureRecognizer:self.oneTapRecognizer];
}

- (void)setupMainScrollView
{
    _scrollView = [UIScrollView new];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.scrollView];
    NSUInteger page = location.x / self.width;
    
    if (self.itemTapped) {
        self.itemTapped(page);
    }
}

- (void)setItemBufferSize:(NSInteger)itemBufferSize
{
    _itemBufferSize = itemBufferSize;
    if (_itemBufferSize % 2 == 0) {
        _itemBufferSize++;
    }
}

- (void)populate
{
    [self clear];
    [self populatePageControl];
    
    if (self.numberOfItems > 0 && self.itemAtIndex) {
        [self showItemAtIndex:self.currentItem];
        [self layoutSubviews];
    }
}

- (void)populatePageControl
{
    if (self.dependedPageControl) {
        self.dependedPageControl.numberOfPages = self.numberOfItems;
        self.dependedPageControl.currentPage = self.currentItem;
    }
}

- (void)showItemAtIndex:(NSInteger)index
{
    NSInteger offset = (self.itemBufferSize - 1) / 2;
    for (NSInteger i = index - offset; i < index + offset; i++) {
        [self placeItemAtIndex:i];
    }
    [self clearExtraItems];
    [self updateItemFramesHiddenOnly:YES];
}

- (void)placeItemAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.numberOfItems) return;
    
    if (!self.placedItems[@(index)]) {
        UIView *item = self.itemAtIndex(index);
        NAZoomContainer *container = [self createZoomContainerByItem:item];
        self.placedItems[@(index)] = container;
        [self.scrollView addSubview:container];
    }
}

- (void)clearExtraItems
{
    [self.placedItems.allKeys enumerateObjects:^(NSNumber *key) {
        NSInteger diff = ABS(key.integerValue - self.currentItem);
        NSInteger offset = (self.itemBufferSize - 1) / 2;
        if (diff > offset) {
            UIView *item = self.placedItems[key];
            [item removeFromSuperview];
            [self.placedItems removeObjectForKey:key];
        }
    }];
}

- (void)clear
{
    [self.placedItems.allKeys enumerateObjects:^(NSNumber *key) {
        UIView *view = self.placedItems[key];
        [view removeFromSuperview];
    }];
    [self.placedItems removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    [self layoutItems];
}

- (NAZoomContainer *)createZoomContainerByItem:(UIView *)view
{
    NAZoomContainer *container;
    if (self.zoomEnable) {
        container = [[NAZoomContainer alloc] initWithView:view scale:self.maxScale];
    } else {
        container = [[NAZoomContainer alloc] initWithView:view];
    }
    [container takeIntoOneTapRecognizer:self.oneTapRecognizer];
    container.doubleTapScale = self.doubleTapScale;
    return container;
}

- (void)layoutItems
{
    [self updateItemFramesHiddenOnly:NO];
    
    CGFloat width = self.scrollView.width;
    CGFloat height = self.scrollView.height;
    
    self.scrollView.contentSize = CGSizeMake(width * self.numberOfItems, height);
    [self.scrollView scrollRectToVisible:CGRectMake(width * self.strongCurrentItem, 0, width, height)
                                animated:NO];
}

- (void)updateItemFramesHiddenOnly:(BOOL)hiddenOnly
{
    CGFloat width = self.scrollView.width;
    CGFloat height = self.scrollView.height;
    
    [self.placedItems.allKeys enumerateObjects:^(NSNumber *key) {
        NAZoomContainer *item = self.placedItems[key];
        BOOL itemIsHidden = (ABS(self.scrollView.contentOffset.x - item.x) >= self.width);
        if (!hiddenOnly || itemIsHidden) {
            item.frame = CGRectMake(key.integerValue * width, 0, width, height);
            [item resetZoom];
            [item updateLayout];
        }
    }];
}

#pragma mark - Page Control

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.isDragging) return;
    
    CGFloat scrollOffsetCenter = self.scrollView.contentOffset.x + self.width * 0.5;
    NSUInteger page = scrollOffsetCenter / self.width;
    
    if (page != self.currentItem) {
        _currentItem = page;
        if (self.currentItemChanged) {
            self.currentItemChanged(self.currentItem);
        }
        if (self.dependedPageControl) {
            self.dependedPageControl.currentPage = self.currentItem;
        }
        
        [self showItemAtIndex:self.currentItem];
    }
    
    CGFloat scrollOffset = self.scrollView.contentOffset.x;
    
    if (ABS(scrollOffset - self.currentItem * self.width) < 0.1) {
        [self updateItemFramesHiddenOnly:YES];
        self.strongCurrentItem = self.currentItem;
        if (self.strongItemChanged) {
            self.strongItemChanged(self.strongCurrentItem);
        }
    }
}

@end


