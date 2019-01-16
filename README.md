# 使用方法：
**初始化**
```
_sectionIndexView = [[DSectionIndexView alloc] init];
_sectionIndexView.backgroundColor = [UIColor clearColor];
_sectionIndexView.dataSource = self;
_sectionIndexView.delegate = self;
_sectionIndexView.isShowCallout = YES;
_sectionIndexView.calloutViewType = CalloutViewTypeForUserDefined;
_sectionIndexView.calloutDirection = SectionIndexCalloutDirectionLeft;
_sectionIndexView.calloutMargin = 100.f;
_sectionIndexView.calloutText = self.sections.copy;
[self.view addSubview:self.sectionIndexView];
```
**数据代理**
```
- (NSInteger)numberOfItemViewForSectionIndexView:(DSectionIndexView *)sectionIndexView {
    return self.tableview.numberOfSections;
}

- (DSectionIndexItemView *)sectionIndexView:(DSectionIndexView *)sectionIndexView itemViewForSection:(NSInteger)section {
    DSectionIndexItemView *itemView = [[DSectionIndexItemView alloc] init];  
    itemView.titleLabel.text = [self.sections objectAtIndex:section];
    itemView.titleLabel.font = [UIFont systemFontOfSize:12];
    itemView.titleLabel.textColor = [UIColor darkGrayColor];
    itemView.titleLabel.highlightedTextColor = [UIColor redColor];
    itemView.titleLabel.shadowColor = [UIColor whiteColor];
    itemView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    return itemView;
}
//点击
- (void)sectionIndexView:(DSectionIndexView *)sectionIndexView didSelectSection:(NSInteger)section {
    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

```

**如果提示视图无法满足要求，可以自定义**
```
- (UIView *)sectionIndexView:(DSectionIndexView *)sectionIndexView calloutViewForSection:(NSInteger)section {

}
```
