
% -------------------------------------------------------------------------
dpathimread = '';
filenames = dir([dpathimread '*.bmp']);
% Path to save images
dpathsaveimg = '\';
tic

for i = 1:Num_of_imgs % 1:40
    grayimage=imread([dpathimread filenames(i).name]);
    
%     if size(grayimage,1)== 512 % NIST images
    grayimage(511:512,:)=[];
    binarizeImage = binarize_nistsd4_straightforward(grayimage);
    % binarizeImage = binarize_nistsd4_challenging(grayimage); # could use
    % this rather
    newname=filenames(i).name;
    newfile=[dpathsaveimg newname, '.bmp'];
    
    imwrite(binarizeImage, newfile, 'bmp' );
  {i, newname} 

end
toc
%  Elapsed time is 