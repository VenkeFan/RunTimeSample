//
//  NSObject+AssociatedObject.m
//  RunTimeSample
//
//  Created by fanqi on 17/4/19.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "NSObject+AssociatedObject.h"
#import <objc/runtime.h>

BOOL swizzleInstanceMethod(Class cls, SEL originalSel, SEL swizzledSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    if (!originalMethod || !swizzledMethod) {
        return NO;
    }
    
    BOOL didAdded = class_addMethod(cls,
                                    originalSel,
                                    method_getImplementation(swizzledMethod),
                                    method_getTypeEncoding(swizzledMethod));
    if (didAdded) {
        class_replaceMethod(cls,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    return YES;
}

BOOL swizzleClassMethod(Class cls, SEL originalSel, SEL swizzledSel) {
    Method originalMethod = class_getClassMethod(cls, originalSel);
    Method swizzledMethod = class_getClassMethod(cls, swizzledSel);
    if (!originalMethod || !swizzledMethod) {
        return NO;
    }
    
    BOOL didAdded = class_addMethod(objc_getMetaClass([NSStringFromClass(cls) UTF8String]),
                                    originalSel,
                                    method_getImplementation(swizzledMethod),
                                    method_getTypeEncoding(swizzledMethod));
    if (didAdded) {
        class_replaceMethod(objc_getMetaClass([NSStringFromClass(cls) UTF8String]),
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    return YES;
}

@implementation NSObject (AssociatedObject)

+ (void)load {
//    swizzleClassMethod([NSObject class],
//                       @selector(resolveInstanceMethod:),
//                       @selector(swizzle_resolveInstanceMethod:));
    
//    swizzleInstanceMethod([self class],
//                          @selector(forwardingTargetForSelector:),
//                          @selector(swizzle_forwardingTargetForSelector:));
    
    swizzleInstanceMethod([self class],
                          @selector(methodSignatureForSelector:),
                          @selector(swizzle_methodSignatureForSelector:));
    swizzleInstanceMethod([self class],
                          @selector(forwardInvocation:),
                          @selector(swizzle_forwardInvocation:));
}


/**
 方法一：几乎所有的系统方法都会进这里
 */
//+ (BOOL)swizzle_resolveInstanceMethod:(SEL)sel {
//    NSLog(@"swizzle_resolveInstanceMethod: sel = %@", NSStringFromSelector(sel));
//
//    if (sel == @selector(sendMessage:)) {
//        class_addMethod([NSObject class], sel, imp_implementationWithBlock(^(id self, NSString *word) {
//            NSLog(@"-----> resolution way : %@ = %@", NSStringFromSelector(sel), word);
//        }), "v@*");
//
//        return YES;
//    }
//
//    return [self swizzle_resolveInstanceMethod:sel];
//}


/**
 方法二：目前本例中除了真正想捕获的“sendMessage:”方法，还有一个系统方法进了这里
 */
//- (id)swizzle_forwardingTargetForSelector:(SEL)aSelector {
//    NSLog(@"swizzle_forwardingTargetForSelector: sel = %@", NSStringFromSelector(aSelector));
//
//    if (![self respondsToSelector:aSelector]) {
//        class_addMethod([self class], aSelector, imp_implementationWithBlock(^(id self, NSString *word) {
//            NSLog(@"-----> swizzle_fastforwarding way : %@ = %@", NSStringFromSelector(aSelector), self);
//        }), "v@*");
//
//        return [[self class] new];
//    }
//
//    return [self swizzle_forwardingTargetForSelector:aSelector];
//}


/**
 方法三：只捕获到了“sendMessage:”
 */
- (NSMethodSignature *)swizzle_methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"swizzle_methodSignatureForSelector: sel = %@", NSStringFromSelector(aSelector));
    
    NSMethodSignature *methodSignature = [self swizzle_methodSignatureForSelector:aSelector];

    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }

    return methodSignature;
}

- (void)swizzle_forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"-----> swizzle_forwardInvocation way : %@ = %@", NSStringFromSelector(anInvocation.selector), self);
}

- (void)setAssociatedObject:(id)associatedObject {
    objc_setAssociatedObject(self, @selector(associatedObject), associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}

@end
