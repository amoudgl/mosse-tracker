# mosse-tracker
This is a MATLAB implementation of Minimum Output Sum of Squared Error (MOSSE) tracking algorithm.

Details regarding the tracking algorithm can be found in the following paper:

[Visual Object Tracking using Adaptive Correlation Filters](http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=5539960).   
David S. Bolme, J. Ross Beveridge, Bruce A. Draper, Yui Man Lui.   
Computer Vision and Pattern Recognition (CVPR), 2010 IEEE Conference on. IEEE, 2010.


## Output

![Surfer result gif](results/surfer_mosse.gif)

## Dependencies

* MATLAB
* MATLAB Vision Toolbox

## How to run

* Start MATLAB and navigate to project directory.
* Navigate to `src/` directory.   
   `>> cd src`
* Run the `mosse` MATLAB script.   
   `>> mosse`
* First frame of the video will popup; select the object to track.
* The tracker script will show subsequent frames with appropriate bounding boxes.

To run on your dataset, simply change the path in `src/mosse.m` script.   

## License

MIT









