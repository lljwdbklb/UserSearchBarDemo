//
//  WJUserSearchBar.m
//  SearchDemo
//
//  Created by ljjun on 15/9/22.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import "WJUserSearchBar.h"
#import "WJUser.h"

#import "UITextField+WJ.h"

@interface __WJUserSearchBarItem : UIButton
@property (strong, nonatomic) id<WJUser> user;
@end


@implementation __WJUserSearchBarItem

- (void)setUser:(id<WJUser>)user {
    _user = user;
    [self setImage:[user avatar] forState:UIControlStateNormal];
}


@end


@interface WJUserSearchBar ()<WJTextFieldDelegate>
@property (weak, nonatomic) NSLayoutConstraint *wj_scrollWidthConstraint;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray<__WJUserSearchBarItem *> *items;

@property (strong, nonatomic) __WJUserSearchBarItem *searchItem;
@end


@implementation WJUserSearchBar

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}
- (void)awakeFromNib {
    [self setupUI];
    self.searchTextView.delegate = self;
    self.userScrollView.delegate = self;
    self.searchTextView.returnKeyType = UIReturnKeySearch;
    self.dataList = [NSMutableArray array];
    self.items = [NSMutableArray array];
    
    UIImage *image = [UIImage imageNamed:@"tt_search"];
    __WJUserSearchBarItem *search = [[__WJUserSearchBarItem alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [search setBackgroundColor:[UIColor blackColor]];
    [search setImage:image forState:UIControlStateNormal];
    [search setContentMode:UIViewContentModeCenter];
    [self.userScrollView addSubview:search];
    self.searchItem = search;
    
    [self addObserver:self forKeyPath:@"dataList" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    [self addSubview:scrollView];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
//    scrollView.automaticallyAdjustsScrollViewInsets = NO;
    self.userScrollView = scrollView;
    UITextField *textField = [[UITextField alloc]init];
    [self addSubview:textField];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchTextView = textField;
    textField.placeholder = @"搜索";
    
    NSLayoutConstraint *ts_c = [NSLayoutConstraint constraintWithItem:self.userScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.userScrollView.superview addConstraint:ts_c];
    NSLayoutConstraint *bs_c = [NSLayoutConstraint constraintWithItem:self.userScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.userScrollView.superview addConstraint:bs_c];
    NSLayoutConstraint *ls_c = [NSLayoutConstraint constraintWithItem:self.userScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.userScrollView.superview addConstraint:ls_c];
    NSLayoutConstraint *ws_c = [NSLayoutConstraint constraintWithItem:self.userScrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:52];
    [self.userScrollView addConstraint:ws_c];
    self.wj_scrollWidthConstraint = ws_c;

//    [scrollView updateConstraintsIfNeeded];
//    [scrollView setContentSize:CGSizeMake(54, 0)];
    
    
    NSLayoutConstraint *tt_c = [NSLayoutConstraint constraintWithItem:self.searchTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.searchTextView.superview addConstraint:tt_c];
    NSLayoutConstraint *bt_c = [NSLayoutConstraint constraintWithItem:self.searchTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.searchTextView.superview addConstraint:bt_c];
    NSLayoutConstraint *lt_c = [NSLayoutConstraint constraintWithItem:self.searchTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userScrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.searchTextView.superview addConstraint:lt_c];
    NSLayoutConstraint *rt_c = [NSLayoutConstraint constraintWithItem:self.searchTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.searchTextView.superview addConstraint:rt_c];
}

- (void)setText:(NSString *)text {
    [self.searchTextView setText:text];
    [self unSelectedItems];
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:text];
    }
}


- (void)dealloc {
    NSLog(@"remove");
//    [self removeObserver:self forKeyPath:@"dataList"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
//    __weak typeof(self) weakSelf = self;
    CGFloat margin = 8;
//    [self.dataList enumerateObjectsUsingBlock:^(id<WJUser> obj, NSUInteger idx, BOOL *stop) {
//        __WJUserSearchBarItem *item = [weakSelf.items objectForKey:obj.objID];
//        [item setFrame:CGRectMake(margin + idx * (40) , margin, 30, 30)];
//    }];
    
    
    [self.items enumerateObjectsUsingBlock:^(__WJUserSearchBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item setFrame:CGRectMake(margin + idx * (40) , margin, 30, 30)];
    }];
    
    
}


#pragma mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(!self.dataList.count) {
        self.wj_scrollWidthConstraint.constant = 10;
    }
    [self.searchItem removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!textField.text.length && !self.dataList.count) {
        if (![self.userScrollView.subviews containsObject:self.searchItem]) {
            self.wj_scrollWidthConstraint.constant = 50;
            [self.userScrollView addSubview:self.searchItem];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    
    return YES;
}

//- (void)textFieldDidChange:(UITextField *)textField
- (void)textFieldDidChange:(NSNotification *)notification{
    UITextField *textField = notification.object;
    if (!notification||textField == self.searchTextView) {
        
        NSLog(@"textFieldDidChange");
        [self unSelectedItems];
        if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
            [self.delegate searchBar:self textDidChange:textField.text];
        }
    }
}

- (void)textFieldDidDeleteBackward:(UITextField *)textField {
    if (textField.text.length == 0) {
        id <WJUser>user = [self.dataList lastObject];
        if ([self isSelectedItem:user]) {
            [self removeUser:user];
        } else {
            [self selectItem:user];
        }
    }
}

//- (void)willDeleteBackwardAtTextFiled:(UITextField *)textField {
//    
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

#pragma mark scroll item
- (void)addScrollItem:(id <WJUser>)user {
    if ([self.dataList containsObject:user]) {
        __WJUserSearchBarItem *item = [[__WJUserSearchBarItem alloc]init];
        [item setUser:user];
        [item addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.userScrollView addSubview:item];
//        [self.items wj_setObject:item forKey:user.objID];
        [self.items addObject:item];
        [self setNeedsLayout];
        [self unSelectedItems];
    }
}

- (void)clickItem:(__WJUserSearchBarItem *)item {
    [self removeUser:item.user];
}

- (BOOL)isSelectedItem:(id <WJUser>)user {
    if (!user) {
        return NO;
    }
    NSInteger index = [self.dataList indexOfObject:user];
    __WJUserSearchBarItem *item = [self.items objectAtIndex:index];
    if (item) {
        return item.selected;
    }
    return NO;
}

- (void)unSelectedItems {
    __weak typeof(self) weakSelf = self;
    [self.dataList enumerateObjectsUsingBlock:^(id <WJUser>obj, NSUInteger idx, BOOL *stop) {
        NSInteger index = [self.dataList indexOfObject:obj];
        __WJUserSearchBarItem *item = [weakSelf.items objectAtIndex:index];
        if (item) {
            [item setHighlighted:NO];
            item.selected = NO;
        }
    }];
}

- (void)selectItem:(id <WJUser>)user {
    if (!user) {
        return;
    }
    NSInteger index = [self.dataList indexOfObject:user];
    __WJUserSearchBarItem *item = [self.items objectAtIndex:index];
    if (item) {
        [item setHighlighted:YES];
        item.selected = YES;
    }
}

- (void)removeScrollItem:(id <WJUser>)user {
    if (!user) {
        return;
    }
    NSInteger index = [self.dataList indexOfObject:user];
    __WJUserSearchBarItem *item = [self.items objectAtIndex:index];
    [self unSelectedItems];
    if (item) {
        [item removeFromSuperview];
        [self.items removeObjectAtIndex:index];
        [self setNeedsLayout];
    }
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [self.searchTextView resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    return [self.searchTextView becomeFirstResponder];
}

- (BOOL)isFirstResponder {
    [super isFirstResponder];
    return [self.searchTextView isFirstResponder];
}


#pragma mark public
- (void)removeUser:(id <WJUser>)user {
    if ([self.dataList containsObject:user]) {
        [self removeScrollItem:user];
        [[self mutableArrayValueForKey:@"dataList"] removeObject:user];
        if ([self.delegate respondsToSelector:@selector(searchBar:removeUser:)]) {
            [self.delegate searchBar:self removeUser:user];
        }
    }
}
- (void)addUser:(id <WJUser>)user {
    if (!user || [self.dataList containsObject:user]) {
        return;
    }
    [[self mutableArrayValueForKey:@"dataList"] addObject:user];
//    [self.dataList addObject:user];
    [self addScrollItem:user];
    
}


#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"dataList"]) {
        CGFloat w = 8 + self.dataList.count * (40);
        if(![self.searchTextView isFirstResponder] && self.dataList.count == 0){
            self.wj_scrollWidthConstraint.constant = 50;
            w = 50;
            if (![self.userScrollView.subviews containsObject:self.searchItem]) {
                [self.userScrollView addSubview:self.searchItem];
            }
        } else if(self.dataList.count <= 6) {
            self.wj_scrollWidthConstraint.constant = w;
            [self.searchItem removeFromSuperview];
        }
        [self.userScrollView setContentSize:CGSizeMake(w, 0)];
        [self.userScrollView setContentOffset:CGPointMake(w - self.wj_scrollWidthConstraint.constant, 0) animated:YES];
    }
}
@end
