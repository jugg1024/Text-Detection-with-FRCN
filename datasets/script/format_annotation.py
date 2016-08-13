#!/usr/bin/env python
import argparse
import os
import pprint
import sys
import time
from os.path import isfile, join
from os import listdir
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '../coco-text/coco-text-tool'))
import coco_text

def generate_xml_from_annotation():
  # to be implement
  print 'to be implement'

def format_coco_text():
  print 'format coco_text dataset: 80percent training, 10percent valing, 10percent testing'
  # read annotations
  # in : annotate_id imagename    bbox(xmin,ymin,w,h);
  # out: imgprefix label(text)    bbox1(xmin,ymin,xmax,ymax)
  #      imgprefix label(text)    bbox2
  #  import the annotations of coco-text
  if not os.path.exists('train2014'):
    print 'train2014/ not found, please unzipping'
    return -1;
  if not os.path.exists('COCO_Text.json'):
    print 'COCO_Text.json not found, please unzipping'
    return -1;
    
  train_file = open('formatted_dataset/ImageSets/Main/train.txt','w')
  trainval_file = open('formatted_dataset/ImageSets/Main/trainval.txt','w')
  test_file = open('formatted_dataset/ImageSets/Main/test.txt','w')
  val_file = open('formatted_dataset/ImageSets/Main/val.txt','w')

  annotation_in = coco_text.COCO_Text('COCO_Text.json')
  annotation_out = open('formatted_dataset/images.annotations', 'w')

  # select training image
  ann_ids = annotation_in.getAnnIds(imgIds=annotation_in.train, 
      catIds=[('legibility','legible'),('class','machine printed')])
  print 'train annotations:' + str(len(ann_ids))  
  anns = annotation_in.loadAnns(ann_ids)
  imgid_set = set()
  for ann in anns: 
    im_id_str = str(ann['image_id'])
    imgprefix = im_id_str
    for i in xrange(0, 12 - len(im_id_str)):
      imgprefix = '0' + imgprefix
    imgprefix = 'COCO_train2014_' + imgprefix
    img_name = imgprefix + '.jpg'
    # images.annotations
    bbox = ann['bbox']
    xmin = int(round(bbox[0]))
    ymin = int(round(bbox[1]))
    xmax = int(round(bbox[0] + bbox[2]))
    ymax = int(round(bbox[1] + bbox[3]))
    annotation_out.write(img_name + ' text ' + str(xmin) + ' ' + str(ymin) + ' ' + str(xmax) + ' ' + str(ymax) + '\n')
    if not ann['image_id'] in imgid_set:
      # ImageSets train
      train_file.write(imgprefix + '\n')
      trainval_file.write(imgprefix + '\n')
      # JPEGImages train
      if not os.path.isfile('formatted_dataset/JPEGImages/' + img_name): 
        os.system('mv train2014/' + img_name + ' formatted_dataset/JPEGImages')
    imgid_set.add(ann['image_id'])

  # select valing and testing image
  ann_ids = annotation_in.getAnnIds(imgIds=annotation_in.val, 
      catIds=[('legibility','legible'),('class','machine printed')])
  print 'val annotations:' + str(len(ann_ids))  
  anns = annotation_in.loadAnns(ann_ids)
  imgid_set = set()
  cnt = 0
  for ann in anns:
    cnt += 1
    im_id_str = str(ann['image_id'])
    imgprefix = im_id_str
    for i in xrange(0, 12 - len(im_id_str)):
      imgprefix = '0' + imgprefix
    imgprefix = 'COCO_train2014_' + imgprefix
    img_name = imgprefix + '.jpg'
    # images.annotations
    bbox = ann['bbox']
    xmin = int(round(bbox[0]))
    ymin = int(round(bbox[1]))
    xmax = int(round(bbox[0] + bbox[2]))
    ymax = int(round(bbox[1] + bbox[3]))
    annotation_out.write(img_name + ' text ' + str(xmin) + ' ' + str(ymin) + ' ' + str(xmax) + ' ' + str(ymax) + '\n')
    if not ann['image_id'] in imgid_set:
      # ImageSets train or test
      if cnt % 4 == 1:
        test_file.write(imgprefix + '\n')
      else:
        val_file.write(imgprefix + '\n')
        trainval_file.write(imgprefix + '\n')
      # JPEGImages val or test
      if not os.path.isfile('formatted_dataset/JPEGImages/' + img_name): 
        os.system('mv train2014/' + img_name + ' formatted_dataset/JPEGImages')
    imgid_set.add(ann['image_id'])




def format_byted_chi():
  print 'format byted_chi dataset: 80percent training, 10percent valing, 10percent testing'
  # read annotations
  # in : imgpath                  bbox1(xmin,ymin,xmax,ymax);bbox2;bbox3
  # out: imgprefix label(text)    bbox1(xmin,ymin,xmax,ymax)
  #      imgprefix label(text)    bbox2
  if not os.path.exists('chinese_text_detection'):
    print 'chinese_text_detection/ not found, please unzipping'
    return -1;

  annotation_in = open('chinese_text_detection/image_to_rois.txt', 'r')
  annotation_out = open('formatted_dataset/images.annotations', 'w')
  cnt = 0
  for line in annotation_in:
    strs = line.split()
    assert len(strs) == 2, 'Not regular byted_chi line'
    image_path = strs[0]                   # the first item
    image_name = image_path.split('/')[-1] # the last item
    new_img_name = 'byted_chi_' + str(cnt) + '.jpg';
    # JPEGImages
    os.system('mv chinese_text_detection/' + image_path 
      + ' formatted_dataset/JPEGImages/' + new_img_name)
    bboxes = strs[1].split(';')
    # images.annotations
    for bbox in bboxes:
      box = bbox.split(',')
      assert len(box) == 4, 'Not regular byted_chi bbox'
      annotation_out.write(new_img_name + ' text ' + 
        box[0] + ' ' + box[1] + ' ' + box[2] + ' ' + box[3] + '\n')
    cnt += 1
  folder_num = 5 # cross validation of folder_num folds
  for fold in xrange(0, folder_num):
    folder_dir = 'formatted_dataset/ImageSets/folder_num_' + str(fold)
    # ImageSets
    if not os.path.exists(folder_dir):
      os.makedirs(folder_dir)
    train_file = open(folder_dir + '/train.txt','w')
    trainval_file = open(folder_dir + '/trainval.txt','w')
    test_file = open(folder_dir + '/test.txt','w')
    val_file = open(folder_dir + '/val.txt','w')
    if not os.path.exists(folder_dir):
      os.makedirs(folder_dir)
    annotation_in = open('chinese_text_detection/image_to_rois.txt', 'r')
    cnt = 0
    for line in annotation_in:
      new_img_pre = 'byted_chi_' + str(cnt);
      if cnt % (2 * folder_num) == fold:
        test_file.write(new_img_pre + '\n')          
      elif cnt % (2 * folder_num) == fold + 1:
        val_file.write(new_img_pre + '\n')
        trainval_file.write(new_img_pre + '\n')
      else:
        train_file.write(new_img_pre + '\n')
        trainval_file.write(new_img_pre + '\n')
      cnt += 1

def main(raw_args):
  parser = argparse.ArgumentParser(
  formatter_class = argparse.RawTextHelpFormatter,
  description = 
  '''
  1. Format the dataset annotation into the form of pascal voc:
  ./format_annotation.py --dataset byted-chi
  ''')
  # arguments command 1,2,3
  parser.add_argument('--dataset',
            choices = ['coco-text', 'byted-chi'],
            help = 'Which dataset to format')
  args = parser.parse_args(raw_args)
  working_dir = os.path.join(os.path.dirname(__file__), '../' + args.dataset)
  assert os.path.exists(working_dir), 'Not exists: ' + working_dir
  assert os.path.isdir(working_dir), 'Not a dir: ' + working_dir
  os.chdir(working_dir)
  if not os.path.exists('formatted_dataset/Annotations'):
    os.makedirs('formatted_dataset/Annotations')
  if not os.path.exists('formatted_dataset/ImageSets/Main'):
    os.makedirs('formatted_dataset/ImageSets/Main')
  if not os.path.exists('formatted_dataset/JPEGImages'):
    os.makedirs('formatted_dataset/JPEGImages')
  print 'formating ' + args.dataset
  if args.dataset == "byted-chi":
    print 'remove chinese_text_detection'
    os.system('rm -rf chinese_text_detection')
    print 'unzip chinese_text_detection'
    os.system('tar zxf chinese_text_detection.tar.gz')
    print 'formating ...'
    format_byted_chi()
    os.system('rm -rf formatted_dataset/ImageSets/Main/')
    os.system('ln -s folder_num_0/ formatted_dataset/ImageSets/Main')
  elif args.dataset == "coco-text":
    print 'remove COCO_Text.json'
    os.system('rm COCO_Text.json')
    print 'remove train2014'
    os.system('rm -rf train2014')
    print 'unzip COCO_Text.zip'
    os.system('unzip COCO_Text.zip')
    print 'unzip train2014.zip'
    os.system('unzip train2014.zip')
    print 'formating ...'
    format_coco_text()
  else:
    print "not support dataset, to be implemented"
  os.chdir('../script/')
  os.system('./ann2voc2007.sh ' + args.dataset)
  os.system('./rm_headline.sh ../' + args.dataset)

if __name__ == "__main__":
  main(sys.argv[1:])
