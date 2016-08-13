#!/usr/bin/env python


import sys
import os
import numpy as np
import time
import glob
sys.path.append('thrift_gen_py')

from face_detect import FaceProcess
from face_detect.ttypes import OperationType, OperationDirection, FaceProcessReq, FaceDetectRsp

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

if __name__ == '__main__':
  transport = TSocket.TSocket('127.0.0.1', 8877)
  transport = TTransport.TBufferedTransport(transport)
  protocol = TBinaryProtocol.TBinaryProtocol(transport)
  client = FaceProcess.Client(protocol)
  transport.open()
  file = open('./0.jpg', 'r')
  data = file.read()
  print len(data)
  req = FaceProcessReq('0.jpg', data)
  print req.image_name
  rsp = client.face_detect(req)
  print rsp.status
  print rsp.face_num
  transport.close()



