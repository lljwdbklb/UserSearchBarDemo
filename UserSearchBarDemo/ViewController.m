//
//  ViewController.m
//  SearchDemo
//
//  Created by ljjun on 15/9/22.
//  Copyright © 2015年 ljjun. All rights reserved.
//

#import "ViewController.h"

#import "WJUserSearchBar.h"

#import "WJUserEntity.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,WJUserSearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet WJUserSearchBar *searchBar;
@property (strong, nonatomic) NSArray *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view, typically from a nib.
//    UIView *view = nil;
//    [self.searchBar.userScrollView addSubview:(view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)])];
//    [view setBackgroundColor:[UIColor redColor]];
    NSMutableArray *arrayM = [@[] mutableCopy];
    for (int i = 0; i < 10; i ++) {
        NSInteger rand = arc4random_uniform(4) + 1;
        NSString *icon = [NSString stringWithFormat:@"qqstar%ld",(long)rand];
        WJUserEntity *user = [[WJUserEntity alloc]init];
        user.avatar = [UIImage imageNamed:icon];
        [arrayM addObject:user];
    }
    self.dataList = arrayM;
    
    [self.tableView setEditing:YES];
    
    self.searchBar.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(WJUserSearchBar *)searchBar removeUser:(id<WJUser>)user {
    NSInteger index = [self.dataList indexOfObject:user];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
}


#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentif = @"Cell";
    id<WJUser>user = [self.dataList objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentif];
//    cell.editingAccessoryType = UITab/leViewCellAccessoryDetailButton;
    [cell.imageView setImage:[user avatar]];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld - %ld",(long)indexPath.section,(long)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<WJUser>user = [self.dataList objectAtIndex:indexPath.row];
    [self.searchBar addUser:user];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id<WJUser>user = [self.dataList objectAtIndex:indexPath.row];
    [self.searchBar removeUser:user];

}

- ( UITableViewCellEditingStyle )tableView:( UITableView *)tableView editingStyleForRowAtIndexPath:( NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

@end
