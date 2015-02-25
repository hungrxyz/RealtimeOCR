//
//  CVSquares.cpp
//  OpenCVClient
//
//  Original code from sample distributed with openCV source.
//  Modifications (c) new foundry Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#include "CVSquaresHeader.h"

using namespace std;
using namespace cv;

static int thresh = 50, N = 11;
static float tolerance = 0.01;
static int accuracy = 0;

    //adding declarations at top of file to allow public function (was main{}) at top
static void rectanglessss(const Mat& image, vector<vector<Point> >& squares);

    //this public function performs the role of
    //main{} in the original file 
cv::Mat CVSquaresHeader::detectedSquaresInImage (cv::Mat image, float tol, int threshold, int levels, int acc)
{
    vector<vector<Point> > squares;
    
    if( image.empty() )
        {
        cout << "CVSquares.m: Couldn't load " << endl;
        }

    tolerance = tol;
    thresh = threshold;
    N = levels;
    accuracy = acc;
    
    rectanglessss(image, squares);
    
    if (squares.size() > 0) {
        cv::vector<Point> points;
        
        points = squares[0];
        
        cv::Rect rect = boundingRect(squares[0]);
        cv::Mat croppedRef(image, rect);
        cv::Mat cropped;
        croppedRef.copyTo(cropped);
        
        return cropped;
    }
    else {
        cv::Mat img;
        return img;
    }
    
}


    // returns sequence of squares detected on the image.
    // the sequence is stored in the specified memory storage
    //static void findSquares( const Mat& image, vector<vector<Point> >& squares )

static double angle( Point pt1, Point pt2, Point pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

static void rectanglessss(const Mat& image, vector<vector<Point> >& squares)
{
    squares.clear();
    
    // Convert to grayscale
    Mat gray;
    cvtColor(image, gray, CV_BGR2GRAY);
    
    // Use Canny instead of threshold to catch squares with gradient shading
    Mat bw;
    Canny(gray, bw, 0, 50, 5);
    
    // Find contours
    vector<vector<Point> > contours;
    findContours(bw.clone(), contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    vector<Point> approx;
    Mat dst = image.clone();
    
    for (int i = 0; i < contours.size(); i++)
    {
        // Approximate contour with accuracy proportional
        // to the contour perimeter
        approxPolyDP(Mat(contours[i]), approx, arcLength(Mat(contours[i]), true)*0.02, true);
        
        // Skip small or non-convex objects
        if (fabs(contourArea(contours[i])) < 100 || !isContourConvex(approx))
            continue;
        
        if (approx.size() >= 4 && approx.size() <= 6)
        {
            // Number of vertices of polygonal curve
            int vtc = approx.size();
            cout << vtc << endl;
            
            // Get the cosines of all corners
            vector<double> cos;
            for (int j = 2; j < vtc+1; j++)
                cos.push_back(angle(approx[j%vtc], approx[j-2], approx[j-1]));
            
            // Sort ascending the cosine values
            sort(cos.begin(), cos.end());
            
            // Get the lowest and the highest cosine
            double mincos = cos.front();
            double maxcos = cos.back();
            
            cout << mincos << "\n" << maxcos << endl;
            
            if (vtc == 4 && mincos >= -0.2 && maxcos <= 0.5)
                squares.push_back(approx);
        }
    }
 
}

