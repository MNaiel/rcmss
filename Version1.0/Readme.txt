Online multi-object tracking via robust collaborative model and sample selection (RCMSS) Version 1.0
-------------------------------------------------------------------------------------------------------
This is a Matlab implementation of the RCMSS algorithm [1].  

Copyright 2016 (c) Mohamed A. Naiel (m_naiel@encs.concordia.ca, mohamednaiel@gmail.com, https://sites.google.com/site/mohamednaiel/), all rights reserved. This code can be used for academic purpose only. For other usage, please contact Prof. M. Omair Ahmad (omair@ece.concordia.ca), Department of Electrical and Computer Engineering, Concordia University, Montreal, QC, Canada H3G 1M8. If you used this code in developing your technique or testing this code, please cite the following paper:

Mohamed A. Naiel, M. Omair Ahmad, M.N.S. Swamy, Jongwoo Lim, and Ming-Hsuan Yang, "Online multi-object tracking via robust collaborative model and sample selection", Computer Vision and Image Understanding, August 2016, In Press, DOI: http://dx.doi.org/10.1016/j.cviu.2016.07.003.
-------------------------------------------------------------------------------------------------------
The code can be tested by using the Matlab file named, MultiObjectTrackingMain.m, and this code is ready to be tested on the PETS2009 S2L1 test sequence [7]. 
-------------------------------------------------------------------------------------------------------
Code dependencies: 
1) P. Doll�r Toolbox in [3]
2) The pre-trained pedestrian detector of P. Doll�r et al. in [4]
3) The development kit of the PASCAL Visual Object Classes Challenge 2005 [5]
4) The code of sparsity-based tracker presented in [6]
-------------------------------------------------------------------------------------------------------
References:
[1] M.A. Naiel, M.O. Ahmad, M.N.S. Swamy, J. Lim, and M.-H. Yang, "Online multi-object tracking via robust collaborative model and sample selection", Computer Vision and Image Understanding, August 2016, In Press. 
[2] M.A. Naiel, M.O. Ahmad, M.N.S. Swamy, Y. Wu, and M.-H. Yang, "Online multi-person tracking via robust collaborative model", 21st IEEE International Conference on Image Processing (ICIP), Paris, France, pp. 431 � 435, Oct. 2014. 
[3] piotr_toolbox_V3.01 "http://vision.ucsd.edu/~pdollar/toolbox/doc/"
[4] P. Doll�r, S. Belongie and P. Perona, "The Fastest Pedestrian Detector in the West", BMVC 2010, Aberystwyth, UK.
[5] The PASCAL Visual Object Classes Challenge 2005 Development Kit " http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2005/"
[6] W. Zhong, H. Lu, and M.-H. Yang, �Robust object tracking via sparsity-based collaborative model,� In Proc. Comput. Vis. Pattern Recognit., 2012, pp. 1838�1845.
[7] J. Ferryman, in: Proc. IEEE Workshop Performance Evaluation of Tracking and Surveillance, 2009.
