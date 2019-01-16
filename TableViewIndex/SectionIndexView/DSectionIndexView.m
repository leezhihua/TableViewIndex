//
//  DSectionIndexView.m
//  TableViewIndex
//
//  Created by Dean on 13-4-28.
//  Copyright (c) 2013年 Dean. All rights reserved.
//

#import "DSectionIndexView.h"
#import "DSectionIndexItemView.h"
#import <QuartzCore/QuartzCore.h>


@interface DSectionIndexView (){
    CGFloat   itemViewHeight;
    NSInteger highlightedItemIndex;
}


@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *calloutView;
@property (nonatomic, retain) NSMutableArray *itemViewList;

- (void)layoutItemViews;
- (void)highlightItemForSection:(NSInteger)section;
- (void)unhighlightAllItems;
- (void)selectItemViewForSection:(NSInteger)section;

@end


@implementation DSectionIndexView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroundView = [[UIView alloc] init];
        _backgroundView.clipsToBounds = YES;
        _backgroundView.layer.cornerRadius = 12.f;
        [self addSubview:self.backgroundView];
        [self.backgroundView setHidden:YES];
        
        _itemViewList = [[NSMutableArray alloc] init];
        _calloutMargin = 0.f;
        _fixedItemHeight = 0.f;
        _isShowCallout = YES;
        _calloutDirection = SectionIndexCalloutDirectionLeft;
        _calloutViewType = CalloutViewTypeForUserDefined;
    }
    return self;
}

#define kBackgroundViewLeftMargin  3.f
- (void)setBackgroundViewFrame
{
    self.backgroundView.frame = CGRectMake(kBackgroundViewLeftMargin, 0, CGRectGetWidth(self.frame) - kBackgroundViewLeftMargin*2, CGRectGetHeight(self.frame));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}

- (void)layoutItemViews
{
    if (self.itemViewList.count) {
        itemViewHeight = CGRectGetHeight(self.bounds)/(CGFloat)(self.itemViewList.count);
    }
    
    if (self.fixedItemHeight > 0) {
        itemViewHeight = self.fixedItemHeight;
    }
    
    CGFloat offsetY = 0.f;
    for (UIView *itemView in self.itemViewList) {
        itemView.frame = CGRectMake(0, offsetY, CGRectGetWidth(self.bounds), itemViewHeight);
        offsetY += itemViewHeight;
    }
}

- (void)reloadItemViews
{
    for (UIView *itemView in self.itemViewList) {
        [itemView removeFromSuperview];
    }
    [self.itemViewList removeAllObjects];
    
    NSInteger numberOfItems = 0;
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfItemViewForSectionIndexView:)]) {
        numberOfItems = [_dataSource numberOfItemViewForSectionIndexView:self];
    }
    
    for (int i = 0; i < numberOfItems; i++) {
        if (_dataSource && [_dataSource respondsToSelector:@selector(sectionIndexView:itemViewForSection:)]) {
            DSectionIndexItemView *itemView = [_dataSource sectionIndexView:self itemViewForSection:i];
            itemView.section = i;
            
            [self.itemViewList addObject:itemView];
            [self addSubview:itemView];
        }
    }
    
    [self layoutItemViews];
}


- (void)selectItemViewForSection:(NSInteger)section
{
    [self highlightItemForSection:section];
    
    DSectionIndexItemView *seletedItemView = [self.itemViewList objectAtIndex:section];
    CGFloat centerY = seletedItemView.center.y;
    
    if (self.isShowCallout) {
        if (self.calloutViewType == CalloutViewTypeForUserDefined && _delegate && [_delegate respondsToSelector:@selector(sectionIndexView:calloutViewForSection:)]) {
            self.calloutView = [_delegate sectionIndexView:self calloutViewForSection:section];
            [self addSubview:self.calloutView];
            
            if (centerY - CGRectGetHeight(self.calloutView.frame)/2 < 0) {
                centerY = CGRectGetHeight(self.calloutView.frame)/2;
            }
            if (seletedItemView.center.y + CGRectGetHeight(self.calloutView.frame)/2 > itemViewHeight * self.itemViewList.count) {
                centerY = itemViewHeight * self.itemViewList.count - CGRectGetHeight(self.calloutView.frame)/2;
            }
        }else {
            _calloutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
            if (self.calloutImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:_calloutView.frame];
                imageView.image = self.calloutImage;
                [self.calloutView addSubview:imageView];
            }

            UILabel *tipLabel = [[UILabel alloc] initWithFrame:_calloutView.frame];
            tipLabel.center = CGPointMake(_calloutView.center.x - 5, _calloutView.center.y);
            tipLabel.backgroundColor = [UIColor clearColor];
            if (self.calloutTextAttributes) {
                UIColor *color = self.calloutTextAttributes[NSForegroundColorAttributeName];
                UIFont *font = self.calloutTextAttributes[NSFontAttributeName];
                tipLabel.textColor = color;
                tipLabel.font = font;
            } else {
                tipLabel.textColor = [UIColor redColor];
                tipLabel.font = [UIFont boldSystemFontOfSize:36];
            }
            if (self.calloutText) {
                NSString *text = self.calloutText[section];
                if (text == nil || text.length == 0) {
                    tipLabel.text = @"#";
                } else {
                    tipLabel.text = text;
                }
            }
            tipLabel.textAlignment = NSTextAlignmentCenter;
            [self.calloutView addSubview:tipLabel];
            [self addSubview:self.calloutView];
        }
        
        switch (self.calloutDirection) {
            case SectionIndexCalloutDirectionRight:
                if (self.calloutMargin <= 0) {
                    self.calloutMargin = UIScreen.mainScreen.bounds.size.width/2.0-CGRectGetWidth(_calloutView.frame)/2.0-CGRectGetWidth(seletedItemView.frame)/2.0;
                }
                _calloutView.center = CGPointMake(self.calloutMargin, centerY);
                break;
            case SectionIndexCalloutDirectionLeft:
                if (self.calloutMargin <= 0) {
                    self.calloutMargin = UIScreen.mainScreen.bounds.size.width/2.0-CGRectGetWidth(_calloutView.frame)/2.0;
                }
                _calloutView.center = CGPointMake(-self.calloutMargin, centerY);
                break;
            default:
                break;
        }
    }
    

    
    if (_delegate && [_delegate respondsToSelector:@selector(sectionIndexView:didSelectSection:)]) {
        [_delegate sectionIndexView:self didSelectSection:section];
    }
}

- (void)highlightItemForSection:(NSInteger)section
{
    [self unhighlightAllItems];
    
    DSectionIndexItemView *itemView = [self.itemViewList objectAtIndex:section];
    [itemView setHighlighted:YES animated:YES];
}

- (void)unhighlightAllItems
{
    if (self.isShowCallout) {
        [self.calloutView removeFromSuperview];
        if (self.calloutView) {
            self.calloutView = nil;
        }       
    }
    
    for (DSectionIndexItemView *itemView  in self.itemViewList) {
        [itemView setHighlighted:NO animated:NO];
    }
}


#pragma mark methods of touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundView.hidden = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    for (DSectionIndexItemView *itemView in self.itemViewList) {
        if (CGRectContainsPoint(itemView.frame, touchPoint)) {
            [self selectItemViewForSection:itemView.section];
            highlightedItemIndex  = itemView.section;
            return;
        }
    }
    
    highlightedItemIndex = -1;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundView.hidden = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    for (DSectionIndexItemView *itemView in self.itemViewList) {
        if (CGRectContainsPoint(itemView.frame, touchPoint)) {
            if (itemView.section != highlightedItemIndex) {
                [self selectItemViewForSection:itemView.section];
                highlightedItemIndex  = itemView.section;
                return;

            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundView.hidden = YES;
    [self unhighlightAllItems];
    highlightedItemIndex = -1;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesCancelled:touches withEvent:event];
}

@end
