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
```Shell
ln -s $DOWNLOAD_MODEL_PATH $Text-Detection-with-FRCN/model/vgg16_faster_rcnn_fine_tune_on_coco.caffemodel
```
  3.2 run demo

```Shell
cd $Text-Detection-with-FRCN/
./script/text_detect_demo.sh
```
	Results are on output_img


### Further

  if you think the model is not ok, then you can trainning with your own dataset, take coco-text for example.
  
  + training 

  4.1 download coco-text dataset

```Shell
cd $Text-Detection-with-FRCN/datasets/script
./fetch_dataset.sh coco-text
# download it takes long!
# ensure you have both data and label
# for coco-text label is in COCO-text.json, and data is in train2014.zip
```

  4.2 download pre-train model

```Shell
# finetune on this model, you can also use one model you train before
cd $Text-Detection-with-FRCN/py-faster-rcnn
./data/scripts/fetch_imagenet_models.sh
# download it takes long!
```

  4.3 format the data(you should write your code here)

```Shell
# format the raw image and label into the type of pascal_voc
# follow the code in $Text-Detection-with-FRCN/datasets/script/format_annotation.py
cd $Text-Detection-with-FRCN/datasets/script
./format_annotation.py --dataset coco-text
```
	
  4.4 create a softlink the formatted data to working directorry
       
```Shell
# link your data folder to train_data
cd $Text-Detection-with-FRCN/datasets/
ln -s train_data coco-text    # $YOUR_DATA
```       
        
  4.5 training
      
```Shell
cd $Text-Detection-with-FRCN/py-faster-rcnn/
./experiments/scripts/faster_rcnn_end2end.sh 0 VGG16 pascal_voc
```
