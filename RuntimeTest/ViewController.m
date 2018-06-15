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
    
    [self testMsg];
    
    [self testIMP];
    
    [self hookBlock];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark -

- (void)testMsg {
    NSInteger i = self.tempCount;
    
    [self setValue:@(100) forKey:@"tempCount"];
    NSInteger ii = self.tempCount;
    
    SEL selector = sel_registerName("setTempCount:");//sel_getUid("setTempCount:")
    __unused const char *selName = sel_getName(selector); //"setTempCount:"
    Method method = class_getInstanceMethod([self class], selector);
    __unused const char *encode = method_getTypeEncoding(method);//"v24@0:8q16"
    __unused SEL sel = method_getName(method);
    
    ( (void (*) (id, SEL, NSInteger)) (void*) objc_msgSend) (self, selector, 200);
    NSInteger iii = self.tempCount;
    
    NSLog(@"%ld, %ld, %ld", (long)i, (long)ii, (long)iii);
}

// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
- (void)testIMP {
    SEL selector = sel_getUid("setTempCount:");
    IMP imp = class_getMethodImplementation([self class], selector); //[self methodForSelector:selector];
    void (*zdFunc)(id, SEL, NSInteger) = (void *)imp;//(void (*)(id, SEL, NSInteger))imp;
    zdFunc(self, selector, 7);
    NSLog(@"%ld", (long)self.tempCount);
    NSLog(@"");
}

// https://github.com/ming1016/study/wiki/CFRunLoop
- (void)test {
    // 接到程序崩溃时的信号进行自主处理例如弹出提示等
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    NSArray *allModes = CFBridgingRelease(CFRunLoopCopyAllModes(runLoop));
    while (1) {
        for (NSString *mode in allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
}

- (BOOL)runUntilBlock:(BOOL(^)())block timeout:(NSTimeInterval)timeout {
    __block Boolean fulfilled = NO;
    void (^beforeWaiting) (CFRunLoopObserverRef observer, CFRunLoopActivity activity) = ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        fulfilled = block();
        if (fulfilled) {
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
    };
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, true, 0, beforeWaiting);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // Run!
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout, false);
    
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
    
    return fulfilled;
}

//----------------------------------------------------
enum {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30)  // compiler
};


struct Block_layout {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;         // NULL
        unsigned long int size;             // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, const void *src);     // IFF (1<<25)
        void (*dispose_helper)(const void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
        const char *layout;
    } *descriptor;
    // imported variables
};

void printHookMsg(self, _cmd) {
    NSLog(@"hookBlock");
}

- (void)hookBlock {
    __auto_type block = ^() {
        NSLog(@"block");
    };
    
    //IMP imp = imp_implementationWithBlock(block);
    
    struct Block_layout *layout = (__bridge void *)block;
    if (!(layout->flags & BLOCK_HAS_SIGNATURE)) return;
    
    layout->invoke = (void *)printHookMsg;
    
    block();
}

@end




