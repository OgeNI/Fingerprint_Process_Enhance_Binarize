function binaImage = binarize_nistsd4_straightforward(grayimage)
% -------------------------------------------------------------------------
% This m-file has two steps
% Step 1 removes scars and marks from NIST images or crops out large
% printed marks from fingerprints before binarization.
% Step 2 carries out a local binarization of the image in lines of 51 for
% an image of size 510 by 480. the original image is 512 by 480 but cropped
% to 510 by 480 for the line processing.
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% pass the image
% originalgray=double(grayimage);
originalgray=grayimage;
% -------------------------------------------------------------------------
% STEP 1
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Remove Scars
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get Global mean, minimum and variance of dark pixels
 gray_img_columnized =  double(originalgray(:)); 
mean_dark_pixels=mean(gray_img_columnized(gray_img_columnized < 180));
Var_dark_pixels=var(gray_img_columnized(gray_img_columnized < 180));
    
%  determine lowest pixel values from the average value of 500 pixels darkest vlaues
Gsorted=sort(gray_img_columnized);
minimum_dark_pixels=round(mean(Gsorted(1:500)));
% %  determine maximum pixel value from the average value of 500 pixels lightest vlaues
% Psort=sort(gray_img_columnized, 'descend');
% Global_pixel_lightest=round(mean(Psort(1:500)));

% if the light pixel variance is high then that means that the light
% background is unvenly light, but if low, it is almost evenly light.
% Determine a global light pixel threshold for the image with the use of
% the variance computed.

% STEP 2
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
binarizeIm = NISTSD4_binarization(originalgray,Var_dark_pixels,mean_dark_pixels,minimum_dark_pixels);
binaImage = binarizeIm;
end
% -------------------------------------------------------------------------
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% #########################################################################
