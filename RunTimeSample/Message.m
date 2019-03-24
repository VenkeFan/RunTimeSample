//
//  Message.m
//  RunTimeSample
//
//  Created by fanqi on 17/4/19.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "Message.h"
#import "MessageForwarding.h"
#import <objc/runtime.h>

@implementation Message

/*
 Method Resolution：由于Method Resolution不能像消息转发那样可以交给其他对象来处理，所以只适用于在原来的类中代替掉。
 Fast Forwarding：它可以将消息处理转发给其他对象，使用范围更广，不只是限于原来的对象。
 Normal Forwarding：它跟Fast Forwarding一样可以消息转发，但它能通过NSInvocation对象获取更多消息发送的信息，例如：target、selector、arguments和返回值等信息。
 */

//- (void)sendMessage:(NSString *)word {
//    NSLog(@"normal way : send message = %@", word);
//}

#pragma mark - Method Resolution

// override resolveInstanceMethod or resolveClassMethod for changing sendMessage method implementation
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(sendMessage:)) {
//        class_addMethod([self class], sel, imp_implementationWithBlock(^(id self, NSString *word) {
//            NSLog(@"method resolution way : send message = %@", word);
//        }), "v@*");
//
//        return YES;
//    }
//
//    return [super resolveInstanceMethod:sel];
//}


#pragma mark - Fast Forwarding

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if (aSelector == @selector(sendMessage:)) {
//        return [MessageForwarding new];
//    }
//
//    return nil;
//}


#pragma mark - Normal Forwarding

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
//
//    if (!methodSignature) {
//        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
//    }
//
//    return methodSignature;
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    /// 1.
//    // 这方法里啥也不干，也不会引发“unrecognized selector sent to instance”崩溃
//    
//    /// 2.
////    MessageForwarding *messageForwarding = [MessageForwarding new];
////
////    if ([messageForwarding respondsToSelector:anInvocation.selector]) {
////        [anInvocation invokeWithTarget:messageForwarding];
////    }
//}

@end
