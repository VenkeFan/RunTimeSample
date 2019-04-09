//
//  ViewController.m
//  RunTimeSample
//
//  Created by fanqi on 17/4/19.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ViewController.h"

#import "Son.h"
#import "Message.h"
#import "NSObject+AssociatedObject.h"

//#if TARGET_IPHONE_SIMULATOR
//#import <objc/objc-runtime.h>
//#else
//#import <objc/runtime.h>
//#import <objc/message.h>
//#endif

#import <objc/runtime.h>
#import <objc/message.h>

#import "People.h"

#import "Father+MyAddtion.h"


typedef void(^blk_t)(void);

@interface ViewController ()

@property (nonatomic, copy) blk_t block;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Son *f = [Son new];
    NSLog(@"%@", f.name);
    
    /// 消息发送
//    Son *son = [Son new];
//    son.name = @"tai zi";
//    
//    BOOL b1 = [son isKindOfClass:[Father class]];   // YES  一个对象是否是一个类的实例，或者是派生自该类的类的实例
//    BOOL b2 = [son isMemberOfClass:[Father class]]; // NO   一个对象是否是某个类的实例
//    
//    /// 方法解析与消息转发
//    Message *msg = [Message new];
//    [msg sendMessage:@"hello world"];
    
    /*
     [__NSCFConstantString stringValue] 这种崩溃我没有捕获到
     
     po [@"" class]
     __NSCFConstantString
     
     (lldb) po [[NSArray new] class]
     __NSArray0
     
     (lldb) po [[NSArray alloc] class]
     __NSPlaceholderArray
     
     (lldb) po [@[] class]
     __NSArray0
     
     (lldb) po [@[@"1"] class]
     __NSSingleObjectArrayI
     
     (lldb) po [@[@"1", @"2"] class]
     __NSArrayI
     
     (lldb) po [[NSMutableArray new] class]
     __NSArrayM
     
     (lldb) po [[NSMutableArray alloc] class]
     __NSPlaceholderArray
     
     (lldb) po [[NSString new] class]
     __NSCFConstantString
     
     (lldb) po [[NSString alloc] class]
     NSPlaceholderString
     
     (lldb) po [[NSDictionary new] class]
     __NSDictionary0
     
     (lldb) po [[NSDictionary alloc] class]
     __NSPlaceholderDictionary
     */
//    id str = @"123";
//    NSString *tmp = [str stringValue];
//
//    /// Associated Objects
//    NSObject *obj = [NSObject new];
//    obj.associatedObject = son;
//    NSLog(@"NSObject associatedObject = %@", ((Son *)obj.associatedObject).name);

 
//    runtimeTest2();
    
//    getObjectMembers();
    
//    testBlock();
}

int algorithm(){
    int array[] = {24, 17, 85, 13, 9, 54, 76, 45, 5, 63};
    int count = sizeof(array)/sizeof(int);
    for (int i = 0; i < count - 1; i ++) {
        for (int j = 0; j < count - 1 - i; j ++) {
            if (array[j] < array[j+1]) {
                int temp = array[j];
                array[j] = array[j+1];
                array[j+1] = temp;
            }
        }
        
        if (i == 0) {
            for (int index = 0; index < count; index ++) {
                printf("%d \n", array[index]);
            }
        }
    }
    for (int index = 0; index < count; index ++) {
        printf("%d \n", array[index]);
    }
    return 0;
}

void sayFunction(id self, SEL _cmd, id some) {
    NSLog(@"%@岁的%@说：%@", object_getIvar(self, class_getInstanceVariable([self class], "_age")),[self valueForKey:@"name"],some);
}

/// 动态创建一个类，并创建成员变量和方法，最后赋值成员变量并发送消息
void runtimeTest() {
    // 动态创建对象 创建一个Person 继承自 NSObject类
    Class People = objc_allocateClassPair([NSObject class], "Person", 0);
    
    // 为该类添加NSString *_name成员变量
    class_addIvar(People, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    // 为该类添加int _age成员变量
    class_addIvar(People, "_age", sizeof(int), sizeof(int), @encode(int));
    
    // 注册方法名为say的方法
    SEL s = sel_registerName("say:");
    // 为该类增加名为say的方法
    class_addMethod(People, s, (IMP)sayFunction, "v@:@");
    
    // 注册该类
    objc_registerClassPair(People);
    
    // 创建一个类的实例
    id peopleInstance = [[People alloc] init];
    
    // KVC 动态改变 对象peopleInstance 中的实例变量
    [peopleInstance setValue:@"苍老师" forKey:@"name"];
    
    // 从类中获取成员变量Ivar
    Ivar ageIvar = class_getInstanceVariable(People, "_age");
    // 为peopleInstance的成员变量赋值
    object_setIvar(peopleInstance, ageIvar, @16);
    
    // 调用 peopleInstance 对象中的 s 方法选择器对应的方法
    // objc_msgSend(peopleInstance, s, @"大家好!");  // 直接这样写会报错，参数过多。可以这样设置解决：Build Setting–> Apple LLVM 7.0 – Preprocessing–> Enable Strict Checking of objc_msgSend Calls 改为 NO。。。以下是推荐写法！！
    ((void (*)(id, SEL, id))objc_msgSend)(peopleInstance,  s, @"大家好");
    
    
    // 当People类或者它的子类的实例还存在，则不能调用objc_disposeClassPair这个方法；因此这里要先销毁实例对象后才能销毁类；
    peopleInstance = nil;
    
    // 销毁类
    objc_disposeClassPair(People);
}

void runtimeTest2() {
    id peopleInstance = [[People alloc] init];
    
    /*
     因为编译后的类已经注册在 runtime 中，类结构体中的 objc_ivar_list 实例变量的链表 和 instance_size 实例变量的内存大小已经确定，
     同时runtime 会调用 class_setIvarLayout 或class_setWeakIvarLayout 来处理 strong weak 引用。所以不能向存在的类中添加实例变量
     */
    {
        // add ivar will be failed
//        class_addIvar([People class], "_gender", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
//        Ivar genderIvar = class_getInstanceVariable([People class], "_gender");
//        object_setIvar(peopleInstance, genderIvar, @1);
//        const char *varName = ivar_getName(genderIvar);
//        NSString *name = [NSString stringWithUTF8String:varName];
//        NSLog(@"class_addIvar: %@", name);
    }
    
    
    {
        // add method will be succeed
        SEL s = sel_registerName("say:");
        class_addMethod([People class], s, imp_implementationWithBlock(^(id self, SEL _cmd, id some) {
            NSLog(@"class_addMethod: %@", some);
        }), "v@:@");
        ((void (*)(id, SEL, id))objc_msgSend)(peopleInstance,  s, @"大家好");
    }
}

/// 获取类的成员
void getObjectMembers() {
    People *cangTeacher = [[People alloc] init];
    cangTeacher.name = @"苍井空";
    cangTeacher.age = 18;
    [cangTeacher setValue:@"老师" forKey:@"occupation"];
    
    NSDictionary *propertyResultDic = [cangTeacher allProperties];
    for (NSString *propertyName in propertyResultDic.allKeys) {
        NSLog(@"propertyName:%@, propertyValue:%@",propertyName, propertyResultDic[propertyName]);
    }
    
    NSDictionary *ivarResultDic = [cangTeacher allIvars];
    for (NSString *ivarName in ivarResultDic.allKeys) {
        NSLog(@"ivarName:%@, ivarValue:%@",ivarName, ivarResultDic[ivarName]);
    }
    
    NSDictionary *methodResultDic = [cangTeacher allMethods];
    for (NSString *methodName in methodResultDic.allKeys) {
        NSLog(@"methodName:%@, argumentsCount:%@", methodName, methodResultDic[methodName]);
    }
}


void testBlock() {
//    __block int i = 0;
//    NSLog(@"定义前：%p", &i);           //栈区
//    void (^block)(void) = ^{
//        i = 1;
//        NSLog(@"block内部：%p", &i);    //堆区
//    };
//    NSLog(@"定义后：%p", &i);           //堆区
//    block();
    
    
//    NSMutableString *a = [NSMutableString stringWithString:@"Tom"];
//    NSLog(@"\n 定义前：------------------------------------\n\
//          a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);               //a在栈区
//    void (^foo)(void) = ^{
//        a.string = @"Jerry";                                           //修改的是a指向的堆中的内容
//        NSLog(@"\n block内部：------------------------------------\n\
//              a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);           //a在栈区
////        a = [NSMutableString stringWithString:@"William"];           //此时修改的就不是堆中的内容，而是栈中的内容
//    };
//    foo();
//    NSLog(@"\n 定义后：------------------------------------\n\
//          a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);               //a在栈区
}


@end
