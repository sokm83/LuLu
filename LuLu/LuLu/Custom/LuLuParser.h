//
//  LuLuParser.h
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 7..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuLuParser : NSXMLParser <NSXMLParserDelegate>
{
    NSMutableDictionary* root;
    NSMutableArray* dictStack;
    
    NSString* currentElement;
    NSString* value;
}

+ (LuLuParser *)getSharedInstance;

+ (NSDictionary*)parse:(NSData*)data;
- (NSDictionary*)result;

- (void)clear;

@end
