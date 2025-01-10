% -------------------------------------------------------------------------
% Read in FVC Images 
dpathimread='Z:\OGE_MY_FOLDERS\DB_FP_IMAGES\FVC_IMAGES\DB3_A_2000\'; % 
% 
filenames = dir([dpathimread '*.tif']);

Num_of_imgs = size(filenames,1);


% Path to save images

dpathsaveimg1 = '\';
dpathsaveimg2 = '\';

tic

for i = 1:Num_of_imgs
    grayimage=imread([dpathimread filenames(i).name]);
    

    if size(grayimage,1)== 560 % for e.g. FVC db2 2000, 560 X 296
    binarizeImage = binarize_FVC560(grayimage);
    
    newname=filenames(i).name;
    newfile=[dpathsaveimg1 newname, '.bmp'];
    
    imwrite(binarizeImage, newfile, 'bmp' );
    
    else % FVC db1 2002 with non uniform fingerprints' sizes of 388 x 374
%         Resize 388 x 374, to 390 x 375 
        grayimage(375,:)=255;
        grayimage(:,388:390)=255;
%        
    binarizeImage = binarize_FVC388(grayimage);
    
   newname=filenames(i).name;
    newfile=[dpathsaveimg2 newname, '.bmp'];
    
    imwrite(binarizeImage, newfile, 'bmp' );
    
    end
%  newname=filenames(i).name;
%     newfile=[dpathsaveimg newname '.tiff'];
%     
%     save(newfile, 'binarizeImage');   

  {i, newname}

end
toc
