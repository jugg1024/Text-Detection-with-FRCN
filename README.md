### Introduction

Text Detection Using [py-faster-rcnn](https://github.com/rbgirshick/py-faster-rcnn/blob/master/README.md).

This repository is aimed at 

(1) provide an example of training text-detection models using up-to-date models like *faster-rcnn* and *FCN*. 

(2) Dataset preprocessing, and training of multiple datasets.



### COCO-text

first, download the datasets and annotations using fetch-coco-text:

	```Shell
	cd $ROOT/datasets
	./script/fetch_datasets.sh <dataset name>   
	# eg: ./script/fetch_datasets.sh coco-text 
	```
