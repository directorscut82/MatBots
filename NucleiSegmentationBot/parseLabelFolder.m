function [imageList,labelList,classIndices,originalImageSize] = parseLabelFolder(dirPath,resizeFactor)

files = dir(dirPath);

% how many annotated images (all that don't have 'Class' in the name)
nImages = 0;
for i = 1:length(files)
    fName = files(i).name;
    if isempty(strfind(fName,'Class')) && isempty(strfind(fName,'.mat')) && fName(1) ~= '.'
        nImages = nImages+1;
        imagePaths{nImages} = [dirPath filesep fName];
    end
end

% list of class indices per image
classIndices = [];
[imPathStr,imName,imExt] = fileparts(imagePaths{1});
for i = 1:length(files)
    fName = files(i).name;
    k = strfind(fName,'Class');
    if ~isempty(strfind(fName,imName)) && ~isempty(k)
        [~,imn] = fileparts(fName);
        classIndices = [classIndices str2num(imn(k(1)+5:end))];
    end
end
nClasses = length(classIndices);

% read images/labels
imageList = cell(1,nImages);
labelList = cell(1,nImages);
for i = 1:nImages
    I = imread(imagePaths{i});
    if size(I,3) == 2
        I = I(:,:,1);
    elseif size(I,3) == 3
        I = rgb2gray(I);
    end
    originalImageSize = size(I);
    I = imresize(normalize(double(I)),resizeFactor);
    [imp,imn,ime] = fileparts(imagePaths{i});
    L = uint8(zeros(size(I)));
    for j = 1:nClasses
        classJ = imread([imp filesep imn sprintf('_Class%d.png',classIndices(j))]);
        classJ = (classJ(:,:,1) > 0);
        L(classJ) = j;
    end
%     imshow([repmat(255*I,[1 1 3]) label2rgb(L,'winter','k')]), pause

    imageList{i} = I;
    labelList{i} = L;
end

end