//
//  NSObject+AssociatedObject.m
//  RunTimeSample
//
//  Created by fanqi on 17/4/19.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "NSObject+AssociatedObject.h"
#import <objc/runtime.h>

@implementation NSObject (AssociatedObject)

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-protocol-method-implementation"
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([NSStringFromClass([self class]) hasPrefix:@"_"]
        || [self isKindOfClass:NSClassFromString(@"UITextInputController")]
        || [NSStringFromClass([self class]) hasPrefix:@"UIKeyboard"]
        || [methodName isEqualToString:@"dealloc"]) {
        
        return nil;
    }
    
    if (![self respondsToSelector:aSelector]) {
        Class WLGuard = objc_allocateClassPair([NSObject class], "WLGuard", 0);
        
        NSString *msg = [NSString stringWithFormat:@"[%@ %p %@]: unrecognized selector sent to instance", NSStringFromClass([self class]), self, NSStringFromSelector(aSelector)];
        class_addMethod(WLGuard, aSelector, imp_implementationWithBlock(^(id self) {
            NSLog(@"%@", msg);
        }), "v@*");
        
        return [WLGuard new];
    }
    return nil;
}
#pragma clang diagnostic pop


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
 方法三：也会捕获到系统的方法
 */
//- (NSMethodSignature *)swizzle_methodSignatureForSelector:(SEL)aSelector {
//    NSLog(@"swizzle_methodSignatureForSelector: sel = %@", NSStringFromSelector(aSelector));
//
//    NSMethodSignature *methodSignature = [self swizzle_methodSignatureForSelector:aSelector];
//
//    if (!methodSignature) {
//        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
//    }
//
//    return methodSignature;
//}
//
//- (void)swizzle_forwardInvocation:(NSInvocation *)anInvocation {
//    NSLog(@"-----> swizzle_forwardInvocation way : %@ = %@", NSStringFromSelector(anInvocation.selector), self);
//}

#pragma mark - Getter & Setter

- (void)setAssociatedObject:(id)associatedObject {
    objc_setAssociatedObject(self, @selector(associatedObject), associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}

@end
