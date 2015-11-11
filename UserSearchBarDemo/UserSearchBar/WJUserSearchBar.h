//
//  WJUserSearchBar.h
//  SearchDemo
//
//  Created by ljjun on 15/9/22.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WJUser;
@class WJUserSearchBar;

@protocol WJUserSearchBarDelegate <NSObject>
@optional

- (BOOL)searchBarShouldBeginEditing:(WJUserSearchBar *)searchBar;

- (BOOL)searchBarShouldEndEditing:(WJUserSearchBar *)searchBar;

- (void)searchBar:(WJUserSearchBar *)searchBar textDidChange:(NSString *)searchText;

- (void)searchBar:(WJUserSearchBar *)searchBar removeUser:(id <WJUser>)user;
@end


@interface WJUserSearchBar : UIView<UIScrollViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) id <WJUserSearchBarDelegate> delegate;
@property (weak, nonatomic) UIScrollView *userScrollView;
@property (weak, nonatomic) UITextField *searchTextView;

- (void)setText:(NSString *)text;

- (void)addUser:(id <WJUser>)user;
- (void)removeUser:(id <WJUser>)user;
@end

