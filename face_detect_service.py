#!/usr/bin/env python

# --------------------------------------------------------
# Faster R-CNN
# Copyright (c) 2015 Microsoft
# Licensed under The MIT License [see LICENSE for details]
# Written by Ross Girshick
# Modified by Gen Li
# --------------------------------------------------------

"""
Face Detect Service using py-faster-rcnn
"""

"""Set up paths for Fast R-CNN."""

import os.path as osp
import sys

def add_path(path):
    if path not in sys.path:
        sys.path.insert(0, path)
this_dir = osp.dirname(__file__)
# Add caffe to PYTHONPATH
caffe_path = osp.join(this_dir, 'py-faster-rcnn', 'caffe-fast-rcnn', 'python')
add_path(caffe_path)

# Add lib to PYTHONPATH
lib_path = osp.join(this_dir, 'py-faster-rcnn', 'lib')
add_path(lib_path)

# Add tool to PYTHONPATH
tools_path = osp.join(this_dir, 'py-faster-rcnn', 'tools')
add_path(tools_path)

from fast_rcnn.config import cfg
from fast_rcnn.test import im_detect
from fast_rcnn.nms_wrapper import nms
from utils.timer import Timer
import numpy as np
import scipy.io as sio
import caffe, os, sys, cv2
import argparse
from os import listdir
from os.path import isfile, join


import glob
sys.path.append('thrift_gen_py')

from face_detect import FaceProcess
from face_detect.ttypes import OperationType, OperationDirection, FaceProcessReq, FaceDetectRsp

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer


class FaceProcessHandler:
  def __init__(self):
    self.log = {}
    self.net = init_net()

  def face_detect(self, req):
    # serial data to image
    img_arr = np.fromstring(req.image_data, np.uint8)
    im = cv2.imdecode(img_arr, 1)
    height, width = im.shape[0:2]
    # detect im
    dets = detect(self.net, im)
    # number of dets
    ret_num = len(dets)
    rsp = FaceDetectRsp()
    if ret_num > 0:
      status = 'ok'
      max_ind = np.where(dets[:,-1] == dets[:,-1].max())[0]
      # best_ind = 0
      # for ind in range(1, len(dets)):
      #   if dets[ind, -1] > dets[best_ind, -1]:
      bbox = dets[max_ind, :4][0]
      rsp = FaceDetectRsp()
      rsp.status = status
      rsp.face_num = ret_num
      rsp.image_width = width
      rsp.image_height = height
      rsp.left = bbox[0]
      rsp.right = bbox[2]
      rsp.top = bbox[1]
      rsp.bottom = bbox[3]
    else:
      status = 'no face'
      rsp.status = status
      rsp.face_num = ret_num
    return rsp

def detect(net, im):
  """Detect object classes in an image using pre-computed object proposals."""
  # Detect all object classes and regress object bounds
  timer = Timer()
  timer.tic()
  scores, boxes = im_detect(net, im)
  timer.toc()
  print ('Detection took {:.3f}s for '
       '{:d} object proposals').format(timer.total_time, boxes.shape[0])

  # Visualize detections for each class
  CONF_THRESH = 0.9
  NMS_THRESH = 0.3
  im = im[:, :, (2, 1, 0)]
  cls_boxes = boxes[:,4:8]
  cls_scores = scores[:,1]
  dets = np.hstack((cls_boxes,
            cls_scores[:, np.newaxis])).astype(np.float32)
  keep = nms(dets, NMS_THRESH)
  dets = dets[keep, :]
  inds = np.where(dets[:, -1] >= CONF_THRESH)[0]
  dets = dets[inds, :]
  return dets


def parse_args():
  """Parse input arguments."""
  parser = argparse.ArgumentParser(description='Faster R-CNN demo')
  parser.add_argument('--gpu',
            dest='gpu_id',
            help='GPU device id to use [0]',
            default=0,
            type=int)
  parser.add_argument('--cpu',
            dest='cpu_mode',
            help='Use CPU mode (overrides --gpu)',
            action='store_true')
  parser.add_argument('--net',
            dest='net_proto',
            help='Network prototo use',
            default='deploy.prototxt')
  parser.add_argument('--model',
            dest='model_weight',
            help='model weightds used in frcn',
            default='vgg16_faster_rcnn_face_detect_wider_face.caffemodel')
  parser.add_argument('--object',
            dest='detected_object',
            help='object types [face]',
            default='face')
  args = parser.parse_args()
  return args

def init_net():
  cfg.TEST.HAS_RPN = True  # Use RPN for proposals
  args = parse_args()
  this_dir = osp.dirname(__file__)
  # proto txt location
  prototxt = os.path.join(this_dir, 'models', args.detected_object,
            args.net_proto)
  if not os.path.isfile(prototxt):
    raise IOError(('{:s} not found.\n').format(prototxt))
  # caffemodel location
  caffemodel = os.path.join(this_dir, 'models', args.detected_object,
                args.model_weight)
  if not os.path.isfile(caffemodel):
    raise IOError(('{:s} not found.\n').format(caffemodel))
  # set cpu or gpu mode
  if args.cpu_mode:
    caffe.set_mode_cpu()
  else:
    caffe.set_mode_gpu()
    caffe.set_device(args.gpu_id)
    cfg.GPU_ID = args.gpu_id
  # init net
  net = caffe.Net(prototxt, caffemodel, caffe.TEST)
  print '\n\nLoaded network {:s}'.format(caffemodel)
  # Warmup on a dummy image
  im = 128 * np.ones((300, 500, 3), dtype=np.uint8)
  for i in xrange(2):
    _, _= im_detect(net, im)
  return net

if __name__ == '__main__':
  handler = FaceProcessHandler()
  processor = FaceProcess.Processor(handler)
  transport = TSocket.TServerSocket(port=8877)
  tfactory = TTransport.TBufferedTransportFactory()
  pfactory = TBinaryProtocol.TBinaryProtocolFactory()
  server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)
  server.serve()


