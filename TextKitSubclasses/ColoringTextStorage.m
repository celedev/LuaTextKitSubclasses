//
//  ColoringTextStorage.m
//  TextKitSubclasses
//
//

#import "ColoringTextStorage.h"

@interface ColoringTextStorage ()
{
    NSMutableAttributedString* _backingStore;
}

@end

@implementation ColoringTextStorage

- (id)init
{
    self = [super init];
    if (self) {
        _backingStore = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

// Define required methods from NSAttributedString

- (NSString *)string
{
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

// Define required methods from NSMutableAttributedString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
    _dynamicTextNeedsUpdate = YES;
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
