#!/usr/local/bin/thrift --gen cpp --gen py:new_style -o . -r
# mkdir ../thrift_gen_py
# thrift --gen py:new_style -r -out ../thrift_gen_py face_detect.thrift

enum OperationType
{
    DetectFace = 1,             # step 1: detect face
    AlignFace = 2,              # step 2: align face
    ExtrRawFaceFeat = 3,        # step 3: extract raw face features
    ExtrFineFaceFeat = 4,       # step 4: extract fin face features
}
enum OperationDirection
{
    Normal = 1,                 # 直接检测人脸，不进行任何旋转
    AllDirection = 2,           # 从四个方向检测人脸
}

struct FaceProcessReq {
    1: string image_name,                           #图片文件名称，用于打印log追踪问题使用，写id也行
    2: binary image_data,                           #图片的二进制数据
    3: optional OperationType type,                 #处理的参数，针对不同的参数，有不同的策略
    4: optional OperationDirection direction,       #图像处理的方向
}


#人脸检测的返回包
struct FaceDetectRsp {
    1: string status,          #OK 表示提取正常，其他表示其他的错误提示
    2: i32 image_width,        #图片的宽度
    3: i32 image_height,       #图片的高度
    4: i32 face_num,           #检测到的人脸的个数，如果个数>0, 会把最大的人脸位置信息，写入后面的四个字段中
    5: optional i32 left,
    6: optional i32 right,
    7: optional i32 top,
    8: optional i32 bottom,
}

service FaceProcess{
    FaceDetectRsp face_detect(1: FaceProcessReq req),
}

