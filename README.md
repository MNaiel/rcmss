# Online multi-object tracking via robust collaborative model and sample selection (RCMSS)

This repository includes a Matlab implementation of the RCMSS method in [1] [Webpage](https://users.encs.concordia.ca/~rcmss/). 

## Demo:
The code can be tested on the **Datasets/PETS2009/S2_L1** test sequence [7] by running the Matlab file named, **Version1.0/MultiObjectTrackingMain.m**. 

## Qualitative Results:
The following Youtube video includes a sample qualitative results of RCMSS.
[![Watch RCMSS Demo](http://img.youtube.com/vi/lnAUnU596UE/0.jpg)](http://www.youtube.com/watch?v=lnAUnU596UE "Online Multi-Object Tracking Via Robust Collaborative Model and Sample Selection")

More details are available in paper in [1] and its [Webpage](https://users.encs.concordia.ca/~rcmss/).

## Code dependencies: 
1) P. Dollár Toolbox in [3]
2) The pre-trained pedestrian detector of P. Dollár et al. in [4]
3) The development kit of the PASCAL Visual Object Classes Challenge 2005 [5]
4) The code of sparsity-based tracker presented in [6]
    Note: For convienance, a copy from the code dependancies, sample dataset and sample quantitative results are stored under **Dependencies/**, **Datasets/** and **Quantitative Results/** subfolders, respectively.
-------------------------------------------------------------------------------------------------------
## References:
- [1] M.A. Naiel, M.O. Ahmad, M.N.S. Swamy, J. Lim, and M.-H. Yang, "Online multi-object tracking via robust collaborative model and sample selection", Computer Vision and Image Understanding, Volume 154, 2017, Pages 94-107. [PDF](https://users.encs.concordia.ca/~rcmss/include/Papers/CVIU2016.pdf)
- [2] M.A. Naiel, M.O. Ahmad, M.N.S. Swamy, Y. Wu, and M.-H. Yang, "Online multi-person tracking via robust collaborative model", 21st IEEE International Conference on Image Processing (ICIP), Paris, France, pp. 431 – 435, Oct. 2014. 
- [3] *piotr_toolbox_V3.01* "http://vision.ucsd.edu/~pdollar/toolbox/doc/"
- [4] P. Dollár, S. Belongie and P. Perona, "The Fastest Pedestrian Detector in the West", BMVC 2010, Aberystwyth, UK.
- [5] The PASCAL Visual Object Classes Challenge 2005 Development Kit "http://host.robots.ox.ac.uk/pascal/VOC/voc2005/index.html"
- [6] W. Zhong, H. Lu, and M.-H. Yang, “Robust object tracking via sparsity-based collaborative model,” In Proc. Comput. Vis. Pattern Recognit., 2012, pp. 1838–1845.
- [7] J. Ferryman, in: Proc. IEEE Workshop Performance Evaluation of Tracking and Surveillance, 2009.

Copyright 2016 (&copy;) Mohamed A. Naiel all rights reserved.
