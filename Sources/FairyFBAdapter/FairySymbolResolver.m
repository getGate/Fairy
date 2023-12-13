//
//  FairySymbolResolver.m
//  
//
//  Created by 丁力(Leo.D) on 2023/12/5.
//

#import "FairySymbolResolver.h"
@import FirebaseCrashlytics;

// bengin hack firebase
@protocol FBSymbolResover <NSObject>
- (BOOL)loadBinaryImagesFromFile:(NSString*)path;
- (id)frameForAddress:(uint64_t)address;
@end

@protocol FBFrame <NSObject>
@property(nonatomic, copy, nullable) NSString *symbol;
@property(nonatomic, copy, nullable) NSString *rawSymbol;
@property(nonatomic, copy, nullable) NSString *library;
@property(nonatomic, copy, nullable) NSString *fileName;
@property(nonatomic, assign) uint32_t lineNumber;
@property(nonatomic, assign) uint64_t offset;
@property(nonatomic, assign) uint64_t address;

@property(nonatomic, assign) BOOL isSymbolicated;
@end

@protocol FairyFIRCLSInternalReport <NSObject>
- (NSString *)binaryImagePath;
@end
@protocol FairyFIRCLSContextManager <NSObject>
- (id<FairyFIRCLSInternalReport>)report;
@end

@protocol FairyFIRCLSReportManager <NSObject>
- (id<FairyFIRCLSContextManager>)contextManager;
@end

@protocol FairyFIRCrashlytics <NSObject>
- (id<FairyFIRCLSReportManager>)reportManager;
@end

// end hack firebase

@implementation FairyStackFrame
+ (FairyStackFrame *)frameWithAddress:(uint64_t)address
{
    FairyStackFrame *frame = [[self alloc] init];
    frame.address = address;
    frame.isSymbolicated = NO;
    return frame;
}
@end

@interface FairySymbolResolver()
@property (nonatomic, strong) id<FBSymbolResover> realResolver;
@end

@implementation FairySymbolResolver
+ (FairySymbolResolver *)resolver
{
    Class clazz = NSClassFromString(@"FIRCLSSymbolResolver");
    if (clazz) {
        id realResolver =  [[clazz alloc] init];
        return [[self alloc] initWithResolver:realResolver];
    } else {
        return nil;
    }
}

+ (NSString *)binaryImagePath
{
    id<FairyFIRCrashlytics> instance = [FIRCrashlytics crashlytics];
    id<FairyFIRCLSReportManager> reportManager = [instance reportManager];
    id<FairyFIRCLSContextManager> contextManager = [reportManager contextManager];
    id<FairyFIRCLSInternalReport> report = [contextManager report];

    return [report binaryImagePath];
}

- (id)initWithResolver:(id<FBSymbolResover>)resolver
{
    self = [super init];
    self.realResolver = resolver;
    return self;
}

- (BOOL)prepare
{
    NSString *path = [FairySymbolResolver binaryImagePath];

    return [_realResolver loadBinaryImagesFromFile:path];
}

- (nullable FairyStackFrame *)decodeAddress:(uint64_t)address
{
    id<FBFrame> realFrame = [_realResolver frameForAddress:address];
    if (!realFrame) {
        return nil;
    }

    FairyStackFrame *frame = [[FairyStackFrame alloc] init];
    frame.symbol = realFrame.symbol;
    frame.rawSymbol = realFrame.rawSymbol;
    frame.library = realFrame.library;
    frame.fileName = realFrame.fileName;
    frame.lineNumber = realFrame.lineNumber;
    frame.offset = realFrame.offset;
    frame.address = realFrame.address;
    frame.isSymbolicated = realFrame.isSymbolicated;

    return frame;
}
@end
