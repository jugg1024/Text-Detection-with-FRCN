function data_prepare
  datasetname = 'VOC2007';
  output_dir = 'formatted_dataset';
  imgpath = [output_dir '/JPEGImages/'];
  if ~exist(imgpath)
    mkdir(imgpath);
  end
  xmlpath = [output_dir '/Annotations/'];
  if ~exist(xmlpath)
    mkdir(xmlpath);
  end
  train_val_path = [output_dir '/ImageSets/Main'];
  if ~exist(train_val_path)
    mkdir(train_val_path);
  end
  trainval = fopen([train_val_path '/' 'trainval.txt'], 'w');
  train = fopen([train_val_path '/' 'train.txt'], 'w');
  val = fopen([train_val_path '/' 'val.txt'], 'w');
  test = fopen([train_val_path '/' 'test.txt'], 'w');
  file_prefix = 'WIDER_train/images';
  traindata = load('wider_face_split/wider_face_train.mat');
  cnt = 0
  for i=1:length(traindata.face_bbx_list)
    foldername = traindata.event_list{i};
    for j=1:length(traindata.face_bbx_list{i})
        cnt = cnt + 1
        facebbox = traindata.face_bbx_list{i}{j};
        filename = traindata.file_list{i}{j};
        % write traintxt
        formatSpec = '%s\n';
        fprintf(trainval,formatSpec,filename);
        fprintf(train,formatSpec,filename);
        % write xml
        xmlf = [xmlpath '/' filename '.xml'];
        imgfullpath = [file_prefix '/' foldername '/' filename '.jpg'];
        writexml(xmlf, facebbox, datasetname, imgfullpath);
        % move file
        destfullpath = [imgpath '/' filename '.jpg'];
        copyfile(imgfullpath,destfullpath);
    end
  end

  file_prefix = 'WIDER_val/images';
  valdata = load('wider_face_split/wider_face_val.mat');
  for i=1:length(valdata.face_bbx_list)
    foldername = valdata.event_list{i};
    for j=1:length(valdata.face_bbx_list{i})
        cnt = cnt + 1
        facebbox = valdata.face_bbx_list{i}{j};
        filename = valdata.file_list{i}{j};
        % write traintxt
        formatSpec = '%s\n';
        fprintf(trainval,formatSpec,filename);
        fprintf(val,formatSpec,filename);
        % write xml
        xmlf = [xmlpath '/' filename '.xml'];
        imgfullpath = [file_prefix '/' foldername '/' filename '.jpg'];
        writexml(xmlf, facebbox, datasetname, imgfullpath);
        % move file
        destfullpath = [imgpath '/' filename '.jpg'];
        copyfile(imgfullpath,destfullpath);
    end
  end
end

function writexml(xmlf, facebbox, datasetname, imgfullpath)
    info = imfinfo(imgfullpath);
    [~,imgname,~] = fileparts(imgfullpath);
    Createnode = com.mathworks.xml.XMLUtils.createDocument('annotation');
    Root = Createnode.getDocumentElement;
    node = Createnode.createElement('folder');
    node.appendChild(Createnode.createTextNode(datasetname));
    Root.appendChild(node);
    node = Createnode.createElement('filename');
    node.appendChild(Createnode.createTextNode(imgname));
    Root.appendChild(node);
    source_node = Createnode.createElement('source');
    Root.appendChild(source_node);
    node = Createnode.createElement('database');
    node.appendChild(Createnode.createTextNode('WiderFace'));
    source_node.appendChild(node);
    node = Createnode.createElement('annotation');
    node.appendChild(Createnode.createTextNode('WiderFace'));
    source_node.appendChild(node);
    node=Createnode.createElement('image');
    node.appendChild(Createnode.createTextNode('NULL'));
    source_node.appendChild(node);
    node=Createnode.createElement('flickrid');
    node.appendChild(Createnode.createTextNode('NULL'));
    source_node.appendChild(node);
    owner_node=Createnode.createElement('owner');
    Root.appendChild(owner_node);
    node=Createnode.createElement('flickrid');
    node.appendChild(Createnode.createTextNode('NULL'));
    owner_node.appendChild(node);
    node=Createnode.createElement('name');
    node.appendChild(Createnode.createTextNode('ligen'));
    owner_node.appendChild(node);
    size_node=Createnode.createElement('size');
    Root.appendChild(size_node);
    node=Createnode.createElement('width');
    node.appendChild(Createnode.createTextNode(num2str(info.Width)));
    size_node.appendChild(node);
    node=Createnode.createElement('height');
    node.appendChild(Createnode.createTextNode(num2str(info.Height)));
    size_node.appendChild(node);
    node=Createnode.createElement('depth');
    node.appendChild(Createnode.createTextNode(num2str(info.BitDepth / 8)));
    size_node.appendChild(node);
    node=Createnode.createElement('segmented');
    node.appendChild(Createnode.createTextNode('0'));
    Root.appendChild(node);
    [m,~] = size(facebbox);
    for i=1:m
        xmin = max(round(facebbox(i,1)), 1);
        ymin = max(round(facebbox(i,2)), 1);
        xmax = min(round(facebbox(i,1) + facebbox(i,3)), info.Width);
        ymax = min(round(facebbox(i,2) + facebbox(i,4)), info.Height);
        if xmin >= xmax || ymin >= ymax || xmin <= 0 || ymin <= 0 ...
                || xmax > info.Width || ymax > info.Height
            continue;
        end
        object_node=Createnode.createElement('object');
        Root.appendChild(object_node);
        node=Createnode.createElement('name');
        node.appendChild(Createnode.createTextNode('face'));
        object_node.appendChild(node);
        node=Createnode.createElement('pose');
        node.appendChild(Createnode.createTextNode('Unspecified'));
        object_node.appendChild(node);
        node=Createnode.createElement('truncated');
        node.appendChild(Createnode.createTextNode('0'));
        object_node.appendChild(node);
        node=Createnode.createElement('difficult');
        node.appendChild(Createnode.createTextNode('0'));
        object_node.appendChild(node);
        bndbox_node=Createnode.createElement('bndbox');
        object_node.appendChild(bndbox_node);
        node=Createnode.createElement('xmin');
        node.appendChild(Createnode.createTextNode(num2str(xmin)));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('ymin');
        node.appendChild(Createnode.createTextNode(num2str(ymin)));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('xmax');
        node.appendChild(Createnode.createTextNode(num2str(xmax)));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('ymax');
        node.appendChild(Createnode.createTextNode(num2str(ymax)));
        bndbox_node.appendChild(node);
    end
    xmlwrite(xmlf, Createnode);
end
