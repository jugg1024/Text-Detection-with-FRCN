### Text Detection Using [py-faster-rcnn](https://github.com/rbgirshick/py-faster-rcnn/blob/master/README.md).

# image #

### Introduction

This repository is aimed at provide an example of training text-detection models using *faster-rcnn*

### Download repo 

  + Clone the repository
  
  ```Shell
  # Make sure to clone with --recursive
  git clone --recursive https://github.com/jugg1024/Text-Detection-with-FRCN.git
  ```

### Compile

  + Compile py-faster-rcnn

  2.1 change the branch of py-faster-rcnn to text-detection-demo

	```Shell
	cd $Text-Detection-with-FRCN/py-faster-rcnn
    	git checkout text-detection
   ```

  2.2 Build Caffe and pycaffe.

 	```Shell
	# ensure your enviroment support the training of caffeensure your enviroment support the training of caffe
	cd $Text-Detection-with-FRCN/py-faster-rcnn/caffe-fast-rcnn
	cp Makefile.config.example Makefile.config
	# adjust the Makefile.config
	make -j16 && make pycaffe    # here only python api is used.
	# test if caffe python api is ok.
	cd python
	python
	>>> import caffe
	>>> caffe.__version__
	'1.0.0-rc3'
	```

  2.3 Build the Cython modules.

 	```Shell
	cd $Text-Detection-with-FRCN/py-faster-rcnn/lib
	make
	```
	
### Run demo

  + Run text detection demo

  3.1 download pre-trained model

	URL: http://pan.baidu.com/s/1dE2Ori5  Extract Code: phxk

  3.2 run demo

 	```Shell
	cd $Text-Detection-with-FRCN/
	./script/text_detect_demo.sh
	```
