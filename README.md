# RealtimeOCR
Realtime OCR with Tesseract and OpenCV, written in Swift.

Idea behind this project is to recreate the iTunes iOS App's gift card code scanner.

## iOS 9 Branch is hacky! 

### Don't convert to latest Swift version if it asks (It is already converted, don't know why it's comming up). 
**Recommended to Clean (Cmd + Shift + K) the project before building.**

Demo:

[Live preview pointed at the rectangle with text.](OpenCVT/Images.xcassets/ishot_1.imageset/IMG_0708.PNG)

[Cropped rectangle returned from OpenCV](OpenCVT/Images.xcassets/ishot_2.imageset/IMG_0709.PNG)

[Xcode output after applying OCR on the cropped image](OpenCVT/Images.xcassets/xshot.imageset/Screen%20Shot%202015-02-25%20at%2003.39.27.png)



This is my first project with OpenCV and Tesseract so any improvements are welcome.
