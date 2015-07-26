# CVPR15-CFSS
Note this repo is still under construction and would be expected to be finished on Monday.
------

## Description

This is the implementation of Shizhan Zhu et al.'s CVPR-15 work [Face Alignment by Coarse-to-Fine Shape Searching](http://www.cv-foundation.org/openaccess/content_cvpr_2015/papers/Zhu_Face_Alignment_by_2015_CVPR_paper.pdf). It is open source under BSD-3 license (see the `LICENSE` file). Codes can be used freely only for acedemic purpose. If you want to apply it to industrial products, please send an email to Shizhan Zhu at `zhshzhutah2@gmail.com` first.

## Demo Video
We have uploaded our [demo video](http://youtu.be/S4PQ63duO-I) in youtube. The trained model should perform with similar performance as shown in the demo video. Otherwise, the software might have been used in an inappropriate way.

## Citation
If you use the codes as part of your research project, please cite our work as follows:
```
@inproceedings{zhu2015face,
  title={Face Alignment by Coarse-to-Fine Shape Searching},
  author={Zhu, Shizhan and Li, Cheng and Loy, Chen Change and Tang, Xiaoou},
  booktitle={Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition},
  pages={4998--5006},
  year={2015}
}
```

## Dependency
Due to license issues, this implementation uses two publicly avaiable software packages as opposed to our original implementation: 
1. [VLFeat](https://github.com/vlfeat/vlfeat)
2. [LibSVM](https://github.com/cjlin1/libsvm).

## Installation
1. Put all the required dependency packages under the `external` folder. Matlab compatible bainary files must exist. Please note we have put `vl_sift_toosimple.c` in the `external` folder. Please put it into the directory of `external/vlfeat-0.9.20/toolbox/sift` before compiling (and hence its relative Matlab compatible binary file would appear after compiling). This would slightly speed up sift extraction.
2. Put all the 3148 (for training) + 689 (for testing) in the `data` folder. All images could be downloaded at [IBUG page](http://ibug.doc.ic.ac.uk/resources/facial-point-annotations/). Only LFPW, Helen, AFW and IBUG set are required. Please change one of the filename in IBUG set from `x` to `y` to avoid space in filename.

## Notes
1. Training typically requests at least 20 GB of memory (based on the default parameters settings). Training codes are implemented with parallel machenism and a multicore CPU + parpool enabled Matlab environment can significantly reduce the training time.
2. The bounding box given in the testing phase should be equally noisy with that in the training phase. According to our experience, the definition of **equally noisy** indicates: 1) no bias; and 2) equal variance. Bounding box variance larger than 1/6 of face size is regarded as very noisy. Under such circumstances, please consider to increase the searching stages into 4 stages if possible.
3.  

## How to compare with baseline
Reviewer 2 of our work has raised several concerns. Here we would like to address his / her concerns by directly referring to our codes. Reviewer 2 can directly check our responses by performing several experiments according to our guide below.

1. It is not clear how different the coarse-to-fine approach is significantly different to the cascade regression approach. It appears that the improvement is obtained by regressing to the best candidate base shape, which could be interpreted as adding additional stages at the start of the cascade. It is not clear why after the first stage the standard approach would not work (or what impact stage 2 or 3 has). 

    *  Trivially cascading more iterations cannot improve performance. Please change the configuration in `addAll.m` as follows (which degenerates to SDM) and re-train and evaluate the model to see results.
  ```matlab
  config.stageTot = 1;
  config.regs.iterTot = 4; % or much bigger
  ```
    *  The functionality of each searching stage is acutally that the error distribution descripancy between training and testing set along the cascading series is rectified. The transformation is also re-evaluated.
    *  We note finding similar shape examplars is a non-trivial task. See our results on the 565th samples (out of 689), which is exactly our Figure 1 in the paper. A plain SDM cannot find candidate shapes with big mouth in this case. The shape is always trapped in local optima that the nose landmarks are stayed on the upper mouth.
## How do we beat SDM
To validate our algorithm over the baseline SDM, users can directly do the experiments by simply changing two parameters in `addAll.m`. Please refer to the first question in the **Reviews and Rebuttal** section.

## Feedback
Suggestions and opinions of this work (both positive and negative) are greatly welcome. Please contact the author by sending email to `zhshzhutah2@gmail.com`.

## Common Errors
1. Why does the function `svmtrain` or `svmpredict` prompt errors?

   Please note Matlab itself contains such two functions, and their interface is slightly different from those in libSVM. Please make sure you have include the path to libSVM.

## License
BSD-3, see `LICENSE` file for details.
