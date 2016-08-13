function ann2voc2007(input_dir)
  curpath = mfilename('fullpath');
  [pathstr,~,~] = fileparts(curpath)
  if input_dir(end) == '/'
    input_dir = input_dir(1:end-1);
  end
  [~,input_dir,~] = fileparts(input_dir);
  input_dir = [pathstr '/../' input_dir '/formatted_dataset']
  imgpath = [input_dir '/JPEGImages/']
  txtpath = [input_dir '/images.annotations']
  xmlpath_new = [input_dir '/Annotations/'];
  foldername = 'VOC2007';
  coco = containers.Map();
  fidin = fopen(txtpath, 'r');
  cnt = 0;
  while ~feof(fidin)
    tline = fgetl(fidin);
    str = regexp(tline, ' ', 'split');
    xmlname = strrep(str{1},'.jpg','.xml');
    info = imfinfo([imgpath '/' str{1}]);
    str{3} = max(str2double(str{3}), 1);
    str{4} = max(str2double(str{4}), 1);
    str{5} = min(str2double(str{5}), info.Width);
    str{6} = min(str2double(str{6}), info.Height);
    if str{3} >= str{5} || str{4} >= str{6} || str{3} <= 0 || str{4} <= 0 || str{5} > info.Width...
      str{6} > info.Height
      continue;
    end
    cnt = cnt + 1
    if exist([imgpath '/' str{1}])
      if isKey(coco,xmlname)
        Createnode = coco(xmlname);
        object_node = Createnode.createElement('object');
        Root = Createnode.getDocumentElement;
        Root.appendChild(object_node);
        node=Createnode.createElement('name');
        node.appendChild(Createnode.createTextNode(str{2}));
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
        node.appendChild(Createnode.createTextNode(num2str(str{3})));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('ymin');
        node.appendChild(Createnode.createTextNode(num2str(str{4})));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('xmax');
        node.appendChild(Createnode.createTextNode(num2str(str{5})));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('ymax');
        node.appendChild(Createnode.createTextNode(num2str(str{6})));
        bndbox_node.appendChild(node);
      else
        Createnode = com.mathworks.xml.XMLUtils.createDocument('annotation');
        Root = Createnode.getDocumentElement;
        node = Createnode.createElement('folder');
        node.appendChild(Createnode.createTextNode(foldername));
        Root.appendChild(node);
        node = Createnode.createElement('filename');
        node.appendChild(Createnode.createTextNode(str{1}));
        Root.appendChild(node);
        source_node = Createnode.createElement('source');
        Root.appendChild(source_node);
        node = Createnode.createElement('database');
        node.appendChild(Createnode.createTextNode('MS COCO-Text'));
        source_node.appendChild(node);
        node = Createnode.createElement('annotation');
        node.appendChild(Createnode.createTextNode('MS COCO-Text 2014'));
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
        object_node=Createnode.createElement('object');
        Root.appendChild(object_node);
        node=Createnode.createElement('name');
        node.appendChild(Createnode.createTextNode(str{2}));
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
        node.appendChild(Createnode.createTextNode(num2str(str{3})));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('ymin');
        node.appendChild(Createnode.createTextNode(num2str(str{4})));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('xmax');
        node.appendChild(Createnode.createTextNode(num2str(str{5})));
        bndbox_node.appendChild(node);
        node=Createnode.createElement('ymax');
        node.appendChild(Createnode.createTextNode(num2str(str{6})));
        bndbox_node.appendChild(node);
        coco(xmlname) = Createnode;
      end
    end
  end
  fclose(fidin);
  keyss = keys(coco);
  for i = 1:length(keyss)
    xmlwrite([xmlpath_new '/' keyss{i}], coco(keyss{i}));
  end
end
