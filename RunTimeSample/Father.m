//
//  Father.m
//  RunTimeSample
//
//  Created by fanqi on 17/4/19.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "Father.h"

@implementation Father

+ (void)load {
    NSLog(@"Father load");
}

- (instancetype)init {
    if (self = [super init]) {
        self.name = @"Dad";
    }
    return self;
}

- (void)setName:(NSString *)name {
    NSLog(@"父类的setter方法");
    _name = name;
}

@end
