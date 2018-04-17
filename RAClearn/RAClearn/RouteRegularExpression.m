//
//  RouteRegularExpression.m
//  RAClearn
//
//  Created by lee on 2017/10/25.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RouteRegularExpression.h"

@interface RouteRegularExpression()
@property (copy, nonatomic) NSString *routeParamNamePattern;
@end

@implementation RouteRegularExpression

- (instancetype)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError * _Nullable __autoreleasing *)error {
    //初始化方法中将URL匹配的表达式pattern转换为真正的正则表达式
    NSString *transformedPattern = [RouteRegularExpression transformFromPattern:pattern];
    if (self = [super initWithPattern:transformedPattern options:options error:error]) {
        //同时将需要提取的子串的值的Key保存到数组中
        self.routerParamNamesArr = [[self class] routeParamNamesFromPattern:pattern];
    
    }
    return self;
}

//转换为标准的正则表达式和将：后面的key的名字保存到routerParamNamesArr当中
+ (RouteRegularExpression *)expressionWithPattern:(NSString *)pattern {
    return [RouteRegularExpression new];
}

//接受一个Url从而生成匹配结果的对象，匹配结果的对象里存储着路径参数信息和是否匹配的结果。
- (RouteMatchResult *)matchResultForString:(NSString *)string {
    //首先通过自身方法将URL进行匹配得出NSTextCheckingResult结果的数组
    NSArray *array = [self matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    RouteMatchResult *result = [[RouteMatchResult alloc] init];
    if (!array.count) {
        return result;
    }
    result.match = YES;
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    //遍历NSTextCheckingResult结果
    for (NSTextCheckingResult *paramResult in array) {
        //再便利根据初始化的时候提取的子串的Key的数组
        for (int i=1; i<paramResult.numberOfRanges && i<=self.routerParamNamesArr.count; i++) {
            NSString *paramName = self.routerParamNamesArr[i-1];
            //将值取出，然后将key和value放入到paramDict
            NSString *paramValue = [string substringWithRange:[paramResult rangeAtIndex:i]];
            [paramDict setObject:paramValue forKey:paramName];
        }
    }
    //最后赋值给WLRMatchResult对象
    result.paramProperties = paramDict;
    return result;
}

//转换为正则表达式
+ (NSString *)transformFromPattern:(NSString *)pattern {
    
    NSString *WLRRouteParamNamePattern = @"";
    NSString *WLPRouteParamMatchPattern = @"";
    
    NSString *transformedPattern = [NSString stringWithString:pattern];
    //利用:[a-zA-Z0-9-_][^/]+这个正则表达式，将URL匹配的表达式的子串key提取出来，也就是像 /login/:phone([0-9]+)/:name[a-zA-Z-_]这样的pattern，需要将:phone([0-9]+)和:name[a-zA-Z-_]提取出来
    NSArray *paramPatternStrings = [self routeParamNamesFromPattern:pattern];
    NSError *err;
    //再根据:[a-zA-Z0-9-_]+这个正则表达式，将带有提取子串的key全部去除，比如将:phone([0-9]+)去除:phone改成([0-9]+)
    NSRegularExpression *paramNamePatternEx = [NSRegularExpression regularExpressionWithPattern:WLRRouteParamNamePattern options:NSRegularExpressionCaseInsensitive error:&err];
    for (NSString *paramPatternString in paramPatternStrings) {
        NSString *replaceParamPatternString = [paramPatternString copy];
        NSTextCheckingResult *foundParamNamePatternResult = [paramNamePatternEx matchesInString:paramPatternString options:NSMatchingReportProgress range:NSMakeRange(0, paramPatternString.length)].firstObject;
        if (foundParamNamePatternResult) {
            NSString *paramNamePatternString = [paramPatternString substringWithRange:foundParamNamePatternResult.range];
            replaceParamPatternString = [replaceParamPatternString stringByReplacingOccurrencesOfString:paramNamePatternString withString:@""];
        }
        if (!replaceParamPatternString.length) {
            replaceParamPatternString = WLPRouteParamMatchPattern;
        }
        transformedPattern = [transformedPattern stringByReplacingOccurrencesOfString:paramPatternString withString:replaceParamPatternString];
    }
    if (transformedPattern.length && ([transformedPattern characterAtIndex:0] == '/')) {
        transformedPattern = [@"^" stringByAppendingString:transformedPattern];
    }
    //最后结尾要用$符号
    transformedPattern = [transformedPattern stringByAppendingString:@"$"];
    //最后会将/login/:phone([0-9]+)转换为login/([0-9]+)$
    return transformedPattern;

}

- (NSArray *)paramPatternStringsFromPattern:(NSString *)pattern {
    return nil;
}

+ (NSArray *)routeParamNamesFromPattern:(NSString *)pattern {
    return nil;
}

                                    
@end
