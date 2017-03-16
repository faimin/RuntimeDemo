//
//  ViewController.m
//  RuntimeTest
//
//  Created by 符现超 on 2017/2/24.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ZDObjc : NSObject

@property (nonatomic, copy) void(^block)();

@end

@implementation ZDObjc

- (void)dealloc {
    
}

@end

static const void *key = &key;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger tempCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self copyWeakProperty];
    
    [self testSet];
}

//模仿weak属性的实现
- (void)copyWeakProperty {
    NSObject *testObject = [NSObject new];
    
    __weak id weakValue = testObject;
    id(^copyBlock)() = ^id(){
        return weakValue;
    };
    objc_setAssociatedObject(self, key, copyBlock, OBJC_ASSOCIATION_COPY);
    
    testObject = nil;
    
    id(^block)() = objc_getAssociatedObject(self, key);
    if (block) {
        id result = block();
        NSString *description = [result description];
        NSLog(@"%@", description);
    }
}

#pragma mark - KVC 

- (void)testSet {
    NSInteger i = self.tempCount;
    
    [self setValue:@(100) forKey:@"tempCount"];
    NSInteger ii = self.tempCount;
    
    SEL selector = sel_registerName("setTempCount:");
    __unused const char *selName = sel_getName(selector); //"setTempCount:"
    Method method = class_getInstanceMethod([self class], selector);
    __unused const char *encode = method_getTypeEncoding(method);//"v24@0:8q16"
    __unused SEL sel = method_getName(method);
    
    ((void (*) (id, SEL, NSInteger)) (void*) objc_msgSend) (self, selector, 200);
    NSInteger iii = self.tempCount;
    
    NSLog(@"%zd, %zd, %zd", i, ii, iii);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
