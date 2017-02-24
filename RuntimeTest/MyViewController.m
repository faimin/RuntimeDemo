//
//  MyViewController.m
//  RuntimeTest
//
//  Created by 符现超 on 2017/2/24.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "MyViewController.h"
#import <objc/message.h>

static NSString * const identifier = @"cell";

@interface MyViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:({
        CGRect frame = self.tableView.frame;
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){frame.origin, frame.size.width, frame.size.height - 300}];
        view.backgroundColor = [UIColor redColor];
        view.userInteractionEnabled = NO;
        view;
    })];

    NSString *text = ( (NSString* (*)(id, SEL, NSInteger)) (void *) objc_msgSend)(self, sel_registerName("addNumber:"), 100);
    NSLog(@"%@", text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Events

- (NSString *)addNumber:(NSInteger)num {
    NSString *str = [NSString stringWithFormat:@"%zd", num += 10];
    return str;
}

#pragma mark - UITableViewDatasource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", indexPath.row + 1];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    NSLog(@"%0.2f", y);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
