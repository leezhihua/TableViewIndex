//
//  DSectionIndexView.h
//  TableViewIndex
//
//  Created by Dean on 13-4-28.
//  Copyright (c) 2013年 Dean. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DSectionIndexItemView;
@class DSectionIndexView;

@protocol DSectionIndexViewDataSource <NSObject>

- (DSectionIndexItemView *)sectionIndexView:(DSectionIndexView *)sectionIndexView
                         itemViewForSection:(NSInteger)section;

- (NSInteger)numberOfItemViewForSectionIndexView:(DSectionIndexView *)sectionIndexView;
@end

@protocol DSectionIndexViewDelegate <NSObject>
@optional
///自定义选中提示图
- (UIView *)sectionIndexView:(DSectionIndexView *)sectionIndexView calloutViewForSection:(NSInteger)section;

- (void)sectionIndexView:(DSectionIndexView *)sectionIndexView didSelectSection:(NSInteger)section;

@end


typedef NS_ENUM(NSUInteger, SectionIndexCalloutDirection) {
    SectionIndexCalloutDirectionLeft,
    SectionIndexCalloutDirectionRight
};

typedef NS_ENUM(NSUInteger, CalloutViewType) {
    CalloutViewTypeForDefault,   //CalloutView
    CalloutViewTypeForUserDefined
};


@interface DSectionIndexView : UIView

@property (nonatomic, weak) id<DSectionIndexViewDataSource>dataSource;
@property (nonatomic, weak) id<DSectionIndexViewDelegate>delegate;

//选中提示图显示的方向，相对于DSectionIndexView的对象而言
@property (nonatomic, assign) SectionIndexCalloutDirection calloutDirection;

//是否显示选中提示图，默认是YES
@property (nonatomic, assign) BOOL isShowCallout;

//选中提示图的样式
@property (nonatomic, assign) CalloutViewType calloutViewType;

//itemView的高度，默认是根据itemView的数目均分DSectionIndexView的对象的高度
@property (nonatomic, assign) CGFloat fixedItemHeight;

///选中提示图片
@property (nonatomic, strong) UIImage *calloutImage;
///选中提示文字
@property (nonatomic, copy) NSArray *calloutText;
///选中提示文字属性
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *calloutTextAttributes;

//选中提示图与DSectionIndexView的对象边缘的距离
@property (nonatomic, assign) CGFloat calloutMargin;


- (void)reloadItemViews;

- (void)setBackgroundViewFrame;


@end
