//
//  MSCheckInfoUtils.m
//  Sword
//
//  Created by lw on 16/5/8.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSCheckInfoUtils.h"
#import "MSToast.h"

@implementation MSCheckInfoUtils

#pragma mark - 用户信息校验

+ (BOOL)realNameCheckout:(NSString *)string {

    if (!string) {
        return false;
    }
    
    NSString *pattern = @"^[\u4e00-\u9fa5]{1,50}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;

}

+ (BOOL)phoneNumCheckout:(NSString *)num {
    
    if (!num) {
        return false;
    }
    
    NSString *pattern = @"^[1][3,4,5,6,7,8,9]\\d{9}$";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"regular error");
    }
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:num options:NSMatchingReportCompletion range:NSMakeRange(0, num.length)];
    if (result == nil) {
        return false;
    }
    return true;
}

+ (BOOL)passwordCheckout:(NSString *)string {
    
    if (!string) {
        return false;
    }
    
    //@"^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]*$"
    NSString *pattern = @"^(?!^[0-9]+$)(?!^[A-z]+$)(?!^[^A-z0-9]+$)^.{6,16}$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;
}

+ (BOOL)tradePasswordCheckout:(NSString *)string {
  
    if (!string) {
        return false;
    }
    
    NSString *pattern = @"^(?<k1>[0-9])\\k<k1>{5}$";//6位相同数字
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;
}

+ (BOOL)emailCheckout:(NSString *)string {

    if (!string) {
        return false;
    }
    
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"regular error");
    }
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;
    
}

+ (BOOL)checkCode:(NSString *)code{
    
    if (!code) {
        return false;
    }
    
    if (code.length != 6) {
        [MSToast show:NSLocalizedString(@"hint_input_correct_verifycode", @"")];
        return true;
    }
    return false;
}

+ (BOOL)identityCardCheckout:(NSString *)aIDCardNumber {
    if (!aIDCardNumber) {
        return NO;
    }

    NSString *pattern = @"(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:aIDCardNumber options:NSMatchingReportCompletion range:NSMakeRange(0, aIDCardNumber.length)];
    if (result == nil) {
        return NO;
    }

    if (aIDCardNumber.length == 15) {
        return [MSCheckInfoUtils verifyIDCard15:aIDCardNumber];
    }

    if (aIDCardNumber.length == 18) {
        return [MSCheckInfoUtils verifyIDCard18:aIDCardNumber];
    }

    return NO;
}

// private method
+ (BOOL)verifyIDCard18:(NSString *)aIDCardNumber {
    if (![MSCheckInfoUtils verifyIDCardData:aIDCardNumber]) {
        return NO;
    }

    const int powers[] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
    const int verify[] = {1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2};
    int power = 0;
    for (int i = 0; i < 17; ++i) {
        int number = [aIDCardNumber substringWithRange:NSMakeRange(i, 1)].intValue;
        power += number * powers[i];
    }

    NSString *verifyBitStr = [aIDCardNumber substringWithRange:NSMakeRange(17, 1)];
    int lastNumber = 0;
    if ([verifyBitStr isEqualToString:@"x"] || [verifyBitStr isEqualToString:@"X"]) {
        lastNumber = 10;
    } else {
        lastNumber = verifyBitStr.intValue;
    }

    return verify[power % 11] == lastNumber;
}

+ (BOOL)verifyIDCardData:(NSString *)aIDCardNumber {
    int province = [aIDCardNumber substringWithRange:NSMakeRange(0, 2)].intValue;
    if (![MSCheckInfoUtils verifyProvince:province]) {
        return NO;
    }

    int year = [aIDCardNumber substringWithRange:NSMakeRange(6, 4)].intValue;
    int month = [aIDCardNumber substringWithRange:NSMakeRange(10, 2)].intValue;
    int day = [aIDCardNumber substringWithRange:NSMakeRange(12, 2)].intValue;
    if (year < 1900) {
        return NO;
    }
    if (month < 1 || month > 12) {
        return NO;
    }
    if (day < 1 || day > 31) {
        return NO;
    }
    if (month == 2) {
        return (year % 4 == 0) ? (day <= 29) : (day <= 28);
    }
    bool isSmallMonth = (month == 4 || month == 6 || month == 9 || month == 11);
    if (isSmallMonth && day == 31) {
        return NO;
    }
    return YES;
}

+ (BOOL)verifyProvince:(int)provinceCode {
    const int provinceCodes[] = {
        11, 12, 13, 14, 15,
        21, 22, 23,
        31, 32, 33, 34, 35, 36, 37,
        41, 42, 43, 44, 45, 46,
        50, 51, 52, 53, 54,
        61, 62, 63, 64, 65,
        71,
        81, 82,
        91,
        -1 // end
    };

    for(int i = 0, code = 0; code >= 0; ++i) {
        code = provinceCodes[i];
        if (code == provinceCode) {
            return YES;
        }
    }

    return NO;
}

// private method
+ (BOOL)verifyIDCard15:(NSString *)aIDCardNumber {
    int year = [aIDCardNumber substringWithRange:NSMakeRange(6, 2)].intValue;
    int month = [aIDCardNumber substringWithRange:NSMakeRange(8, 2)].intValue;
    int day = [aIDCardNumber substringWithRange:NSMakeRange(10, 2)].intValue;
    if (year < 1 || year > 90) {
        return NO;
    }
    if (month < 1 || month > 12) {
        return NO;
    }
    if (day < 1 || day > 31) {
        return NO;
    }
    if (month == 2 && day > 29) {
        return NO;
    }
    bool isSmallMonth = (month == 4 || month == 6 || month == 9 || month == 11);
    if (isSmallMonth && day == 31) {
        return NO;
    }
    return YES;
}

#pragma mark - 其他校验
//空格
+ (BOOL)spacingCheckout:(NSString *)string {
    
    if (!string) {
        return false;
    }
    
    NSString *pattern = @"^[^\\s]*$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        //包含
        return true;
    }
    //不包含
    return false;
    
}

//非零正实数
+ (BOOL)numberCheckout:(NSString *)string {
    
    if (!string) {
        return false;
    }
    
    NSString *pattern = @"^[0-9]+(\\.[0-9]+)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;
    
}

//最多两位小数
+ (BOOL)amountOfChargeAndCashCheckou:(NSString *)string {
 
    if (!string) {
        return false;
    }
    
    //    NSString *regex = @"^[0-9]+(\\.[0-9]{1,2})?$";
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:regex];
    //    return [predicate evaluateWithObject:string];
    
    NSString *pattern = @"^[0-9]+(\\.[0-9]{1,2})?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;
    
}

//银行卡号校验
+ (BOOL)bankCardNumberCheckout:(NSString *)string {
    if (!string) {
        return false;
    }
    
    return [self bankCardNumber:string];
}

#pragma mark - check bank card number

+ (BOOL)bankCardNumber:(NSString *)string {

    NSString * lastNum = [[string substringFromIndex:(string.length-1)] copy];//取出最后一位
    NSString * forwardNum = [[string substringToIndex:(string.length -1)] copy];//前15或18位
    NSMutableArray * forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<forwardNum.length; i++) {
        NSString * subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }
    
    NSMutableArray * forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i =(int)(forwardArr.count-1); i> -1; i--) {//前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }
    
    NSMutableArray * arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 < 9
    NSMutableArray * arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 > 9
    NSMutableArray * arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0];//偶数位数组
    
    for (int i=0; i< forwardDescArr.count; i++) {
        
        int num = [forwardDescArr[i] intValue];
        if (i%2) {//偶数位
            [arrEvenNum addObject:[NSNumber numberWithInt:num]];
        }else{//奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInt:num * 2]];
            }else{
                int decadeNum = (num * 2) / 10;
                int unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInt:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInt:decadeNum]];
            }
        }
    }
    
    __block  NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];
    
    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];
    
    __block NSInteger sumEvenNumTotal =0 ;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];
    
    NSInteger lastNumber = [lastNum integerValue];
    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;
    
    return (luhmTotal%10 ==0)?YES:NO;
}



@end
