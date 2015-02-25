//
//  CVSquaresHeader.h
//  OpenCVT
//
//  Created by Zel Marko on 19/02/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#ifndef OpenCVT_CVSquaresHeader_h
#define OpenCVT_CVSquaresHeader_h

#import <opencv2/opencv.hpp>

class CVSquaresHeader {
    
public:
    static cv::Mat detectedSquaresInImage(cv::Mat image, float tol, int threshold, int levels, int accuracy);
};

#endif
