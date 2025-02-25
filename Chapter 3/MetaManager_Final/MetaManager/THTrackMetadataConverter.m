//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THTrackMetadataConverter.h"
#import "THMetadataKeys.h"

@implementation THTrackMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    NSNumber *number = nil;
    NSNumber *count = nil;
    
    if ([item.value isKindOfClass:[NSString class]]) {                      // 1
        NSArray *components =
            [item.stringValue componentsSeparatedByString:@"/"];
        if (components.count > 1) {
            number = @([components[0] integerValue]);
            count = @([components[1] integerValue]);
        }
        else {
            number = @([components[0] integerValue]);
        }
    }
    else if ([item.value isKindOfClass:[NSData class]]) {                   // 2
        NSData *data = item.dataValue;
        if (data.length == 8) {
            uint16_t *values = (uint16_t *) [data bytes];
            if (values[1] > 0) {
                number = @(CFSwapInt16BigToHost(values[1]));                // 3
            }
            if (values[2] > 0) {
                count = @(CFSwapInt16BigToHost(values[2]));                 // 4
            }
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];           // 5
    if (number) {
        [dict setObject:number forKey:THMetadataKeyTrackNumber];
    }
    if (count) {
        [dict setObject:count forKey:THMetadataKeyTrackCount];
    }

    return dict;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {

    AVMutableMetadataItem *metadataItem = [item mutableCopy];

    NSDictionary *trackData = (NSDictionary *)value;
    NSNumber *trackNumber = trackData[THMetadataKeyTrackNumber];
    NSNumber *trackCount = trackData[THMetadataKeyTrackCount];

    uint16_t values[4] = {0};                                                // 6
    
    if (trackNumber && ![trackNumber isKindOfClass:[NSNull class]]) {
        values[1] = CFSwapInt16HostToBig([trackNumber unsignedIntValue]);   // 7
    }
    
    if (trackCount && ![trackCount isKindOfClass:[NSNull class]]) {
        values[2] = CFSwapInt16HostToBig([trackCount unsignedIntValue]);    // 8
    }
    
    size_t length = sizeof(values);
    metadataItem.value = [NSData dataWithBytes:values length:length];       // 9

    return metadataItem;
}

@end
