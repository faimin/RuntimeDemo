//
//  MyTableViewController.m
//  RuntimeTest
//
//  Created by 符现超 on 2017/2/24.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "MyTableViewController.h"
#import <objc/runtime.h>

static NSString * const KeyPath = @"contentOffset";

@interface MyTableViewController ()

@end

@implementation MyTableViewController

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:KeyPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self testKVO];
    
    UIView *view = self.view;
    UITableView *tableView = self.tableView;
    // 是同一个对象
    if ([view isEqual:tableView]) {
        NSLog(@"是同一个对象");
    }
    
    CGRect frame = self.tableView.frame;
    CGRect bounds = self.tableView.bounds;
    __unused NSString *frmaeStr = NSStringFromCGRect(frame);
    __unused NSString *boundsStr = NSStringFromCGRect(bounds);
    
    
    [self.view addSubview:({
        UIView *view = [[UIView alloc] initWithFrame:self.tableView.frame];
        view.backgroundColor = [UIColor redColor];
        view;
    })];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *class1 = NSStringFromClass([self.tableView class]);
    NSString *class2 = NSStringFromClass(object_getClass([self.tableView class]));
    NSString *class3 = NSStringFromClass(object_getClass(self.tableView));
    NSString *class4 = NSStringFromClass(objc_getMetaClass(NSStringFromClass(self.tableView.class).UTF8String));
    
    /**
     UITableView,
     UITableView,
     NSKVONotifying_UITableView,
     UITableView
     */
    NSLog(@"\n%@, \n%@, \n%@, \n%@", class1, class2, class3, class4);
}

- (void)testKVO {
    [self.tableView addObserver:self forKeyPath:KeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([KeyPath isEqualToString:KeyPath]) {
        NSValue *value = change[NSKeyValueChangeNewKey];
        CGPoint point = value.CGPointValue;
        CGFloat y = point.y;
        NSLog(@"%0.2f", y);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
