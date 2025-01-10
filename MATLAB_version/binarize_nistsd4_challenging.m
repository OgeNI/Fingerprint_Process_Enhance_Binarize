function binaImage = binarize_nistsd4_challenging(grayimage)
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
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% -------------------------------------------------------------------------
% Step 1: filter out outliers below pixel value of Glowlimit. They are obviously
% not ridges. Check image for such pixels and replace with 255, this is
% done in the first part of the if ... else loop below.
% Filter out outliers in image and replace those pixels with pixel value
% 250, mask the resulting image with the original image. The first part of
% the if ... else loop applies this generally to the image to pixels values
% less than Glowlimit. 
% Or, Filter out outliers of the same pixel value as  ridges in the image.
% Note that ridges are characterized by undulating pixel values like
% [68,72,84,81, 116,123,111, 131, 126, 79, 81, 76, 85 ...] while marks and
% prints or scars are typically characterized by short groups of dark
% pixels in the midst of lighter pixels (if scars are not embedded in
% ridges). Once the group is spotted, the first part of the if ... else
% loop removes them and replaces the pixels with 255.
% These pixels are replace along the horizontal and vertical directions in
% the image and image is combined as one at the end.
% if no such pixels exist, then the scars of marks if present may be
% embedded in ridges, so the reasonable thing to do is to crop the image at
% that point. the next part of the if ... else loop does that. 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if mean_dark_pixels >= 85 && minimum_dark_pixels < 20 % then there are outliers of dark or very dark pixel values
% 
Glowlimit=Glowest+20;
originalgray(originalgray < Glowlimit)= 255; % masked 
if mean_dark_pixels < 95
originalgray(originalgray < 25)= 255; % masked 
else
    originalgray(originalgray < 30)= 255; % masked 
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Now the pixels of value 255 could be numerous in the image and may affect
% the feature extraction algorithm by introducing false ridge ends
% minutiae, hence it may be better to crop the image at these points.
% Determine the sum of 255 along columns and rows
sum255vert=sum(originalgray==255,1);
sum255hort=sum(originalgray==255,2);
% Find the sums above 100 along columns and rows
vertfind=find(sum255vert > 200);
hortfind=find(sum255hort > 200);
% Select an index value for cropping the image along columns and rows by
% choosing the max index value along columns and rows.
    if isempty(vertfind)
        vertlimit=1;
    else 
        vertlimit=max(vertfind);
    end

    if isempty(hortfind)
        hortlimit=1;
    else 
        hortlimit=max(hortfind);
    end
%  Set limits as determined crop the image if required
originalgray=originalgray(hortlimit:end,vertlimit:end);

% originalgray=image_no_outliers;
% ~~~~~~~~~~~~~~~~~ no such pixels, therefore ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% else % there COULD be outliers of same pixel value as ridges



    rows_image=size(originalgray,1);
    cols_image=size(originalgray,2);
    % the image rows and columns.
    % Perform this in the horizontal direction
%     m_threshold=round(mean_dark_pixels+0.1*mean_dark_pixels);
    m_threshold=140;
r=[]; 
for i = 1:rows_image % step in 1 down the image rows
    k=[];
    for j= 1:cols_image/8:cols_image % step in 60 accross the image columns
        m.i.j=originalgray(i, j:(j+59));
%         m.i=originalgray(i,:); % create sub images , vectors,(sub regions) of size...
        % 1 by 31 at each step. Remember the steps increase by 31 in
        % columns

        if sum(m.i.j < m_threshold) < 25 % check for groups of dark pixels in the midst of lighter pixels in a vector of 96 pixels
            find_m=find(m.i.j < m_threshold);
            indexmlow=min(find_m); indexmhigh=max(find_m); span_m=indexmhigh-indexmlow;
            if span_m < 15 && span_m > 5
                m.i.j(m.i.j < m_threshold)=255;
            else
                m.i.j;
            end
        else
            m.i.j;
        end

        k =[k, m.i.j]; % Group a number of sub-regions into a row structure
    end
    r = [r;k]; % Group the rows into cols and rows structure

end

% Perform this in the vertical direction
m_threshold=160;
w_threshold=130;
o=[];
for j = 1:cols_image % step accross the image columns
    p=[];
    for i= 1:rows_image/10:rows_image % step in 32 down the image rows
        w.j.i=originalgray(i:(i+50),j); % create sub images , vectors,(sub regions) of size...
        % 1 by 31 at each step. Remember the steps increase by 31 in
        % columns

         if sum(w.j.i < m_threshold) < 30  % check for groups of dark pixels in the midst of lighter pixels in a vector of 64 pixels
            find_m = find(w.j.i < m_threshold); length_find_m = length(find_m);
            find_non=find(w.j.i >= m_threshold); length_find_non = length(find_non);
            shift_findm = circshift(find_m,1); span_find = abs(find_m - shift_findm); 
            find_w=find(w.j.i < w_threshold);
            shift_findw = circshift(find_w,1); span_findw = abs(find_w - shift_findw); 
%             width_find = max(find_m) - min(find_m);
%             & length_find_m >10
            if (span_find > 1) <= 3 & length_find_non > 30 & length_find_m > 6
                w.j.i(w.j.i < m_threshold)=255;
            elseif (span_find > 1) <= 1 & length_find_m > 15 & length_find_m < 22
                w.j.i(w.j.i < m_threshold)=255;
            elseif (span_findw > 1) <= 1 && find_w > 5 && find_w < 50
                 w.j.i(w.j.i < w_threshold)=255;
            else
                w.j.i;
            end
        else
            w.j.i;
        end

        p =[p; w.j.i]; % Group a number of sub-regions into a row structure
    end
    o = [o,p]; % Group the rows into cols and rows structure
end
%     combine vertical and horizontal images
    HVcomb=max(r,o);
    originalgray=HVcomb;
  % Again, the pixels of value 255 could be numerous in the image and may affect
% the feature extraction algorithm by introducing false ridge ends
% minutiae, hence it may be better to crop the image at these points.
% Determine the sum of 255 along columns and rows  
    sum255vert=sum(originalgray==255,1);
sum255hort=sum(originalgray==255,2);

vertfind=find(sum255vert > 200);
hortfind=find(sum255hort > 200);

if isempty(vertfind)
    vertlimit=1;
else 
    vertlimit=max(vertfind);
end

if isempty(hortfind)
    hortlimit=1;
else 
    hortlimit=max(hortfind);
end

% crop the image if required
originalgray=originalgray(hortlimit:end,vertlimit:end);
%     
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% STEP 2
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

binarizeIm = NISTSD4_binarization(originalgray,Var_dark_pixels,mean_dark_pixels,minimum_dark_pixels);
binaImage = binarizeIm;
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% #########################################################################
