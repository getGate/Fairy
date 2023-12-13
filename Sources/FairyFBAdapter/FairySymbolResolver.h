//
//  FairySymbolResolver.h
//  
//
//  Created by 丁力(Leo.D) on 2023/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 符号化之后的Frame
@interface FairyStackFrame: NSObject
@property(nonatomic, copy, nullable) NSString *symbol;
@property(nonatomic, copy, nullable) NSString *rawSymbol;
@property(nonatomic, copy, nullable) NSString *library;
@property(nonatomic, copy, nullable) NSString *fileName;
@property(nonatomic, assign) uint32_t lineNumber;
@property(nonatomic, assign) uint64_t offset;
@property(nonatomic, assign) uint64_t address;

@property(nonatomic, assign) BOOL isSymbolicated;

+ (FairyStackFrame *)frameWithAddress:(uint64_t)address NS_SWIFT_NAME(frame(with:));
@end

@interface FairySymbolResolver : NSObject
+ (nullable FairySymbolResolver*)resolver NS_SWIFT_NAME(resolver());

- (BOOL)prepare;
- (nullable FairyStackFrame *)decodeAddress:(uint64_t)address NS_SWIFT_NAME(decode(address:));
@end

NS_ASSUME_NONNULL_END
