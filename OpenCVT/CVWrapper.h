//
//  CVWrapper.h
//  OpenCVT
//
//  Created by Zel Marko on 19/02/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CVWrapper : NSObject

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
