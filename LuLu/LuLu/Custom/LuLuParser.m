//
//  LuLuParser.m
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 7..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import "LuLuParser.h"

@implementation LuLuParser

static LuLuParser *instance = nil;
+ (LuLuParser *)getSharedInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [LuLuParser new];
        }
    }
    return instance;
}

+ (NSDictionary*)parse:(NSData*)data {
    LuLuParser* xml = [[LuLuParser alloc] init];
    
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData: data];
    [xmlParser setDelegate: xml];
    [xmlParser parse];
    NSLog(@"XML: %@", [xml result]);
    
    return [[xml result] mutableCopy];
}

- (NSDictionary*)result {
    return root;
}

- (void)clear {
    root = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    /// 변수 초기화
    if (!dictStack) {
        dictStack = [NSMutableArray array];
    }
    
    if (!root) {
        root = [NSMutableDictionary dictionary];
        [dictStack addObject: root];
    }
    
    
    /// 현재 엘리먼트 이름 저장
    currentElement = [NSString stringWithString: elementName];
    value = @"";
    NSLog(@"elem <%@>", elementName);
    
    
    /// 엘리먼트(키)를 만나면 Dictionary를 생성한다.
    NSMutableDictionary* dict = [dictStack lastObject];
    NSMutableDictionary* newDict = [NSMutableDictionary dictionary];
    
    
    /// 같은 이름의 엘리먼트(키)가 없다면, item 추가
    id item = [dict objectForKey: elementName];
    
    if (!item) {
        [dict setObject:newDict forKey: elementName];
    }
    
    /// 같은 이름의 태그(키)가 있다면, Array로 변환
    else {
        if ([item isKindOfClass: [NSDictionary class]]) {
            NSLog(@"Dict class!!");
            
            NSMutableArray* array = [NSMutableArray array];
            [array addObject: item];
            [array addObject: newDict];
            [dict setObject: array forKey: elementName];
            
            NSLog(@"%@", array);
            
            
        } else if ([item isKindOfClass: [NSArray class]]) {
            //NSLog(@"Array class!!");
            NSMutableArray* array = [(NSMutableArray*)item mutableCopy];
            [array addObject: newDict];
            [dict setObject: array forKey: elementName];
            
            NSLog(@"newDict %@", newDict);
            NSLog(@"%@", array);
            
        } else {
            
            /// @TODO: 에러 처리.....
                        NSLog(@"what? %@", [item class]);
        }
    }
    
    
    [dictStack addObject: newDict];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    /// String value를 임시 저장
    value = [value stringByAppendingString: string];
}

- (void)
parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [dictStack removeLastObject];
    NSMutableDictionary* dict = [dictStack lastObject];
    
    /// Leaf Element일 경우 String 저장
    if ([currentElement isEqualToString: elementName]) {
        if (value) {
            [dict setObject:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey: elementName];
        } else {
            [dict setObject:@"" forKey: elementName];
        }
    }
    else {
        NSLog(@"diff! %@ %@", currentElement, elementName);
    }
    
    currentElement = nil;
}

@end
