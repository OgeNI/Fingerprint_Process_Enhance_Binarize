function binarizeImage = binarize_FVC388(grayimage)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
originalgray=grayimage;
% Get Global mean, and variance of dark pixels in preprocessed image.
gray_img_columnized =  double(originalgray(:)); 
mean_dark_pixels=mean(gray_img_columnized(gray_img_columnized < 220));
Var_dark_pixels=var(gray_img_columnized(gray_img_columnized < 220));
% -------------------------------------------------------------------------    
% Format image size first
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rows_image=size(originalgray,1);
cols_image=size(originalgray,2);

% -------------------------------------------------------------------------
%  Binarization starts here
% Image is 375 x 390. divide by 15 and 10 respectively. 
G_var = Var_dark_pixels; % Global variance set

G_Bin_T = mean_dark_pixels; % global binarization threshold set

% Set thresholds for variance and mean - lowand high (6 values
% here).
% The normal range will be between the low and high values for the variance
% and mean
G_var_low = G_var*0.6; % G_var - 0.4 of G_var
G_var_high = G_var*1.4; % G_var + 0.4 of G_var
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
G_mean_low = G_Bin_T*0.85; % G_Bin_T - 0.15 of G_Bin_T
G_mean_high = G_Bin_T*1.15; % G_Bin_T + 0.15 of G_Bin_T
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TYPE I
if mean_dark_pixels < 170 && Var_dark_pixels < 2000 % Global approach is used then for binarization
    r = originalgray < (mean_dark_pixels + 0.04 * mean_dark_pixels);
else
% TYPE II
%     Last condition holds here
%      Images not exhibiting any of the above characteristics in Types I – IV were binarized differently
%     tow_t = 170;
%     Divide image into 16 blocks
    r=[]; 
    for i = 1:rows_image/15:rows_image % step in 1 down the image rows
    %     for i = 1:rows_image/3:rows_image % step in 1 down the image rows
        k=[];
        for j= 1:cols_image/10:cols_image % step in 31 over the image columns
    %         m.i.j=originalgray(i:(i+3), j:(j+95)); % create sub images sub regions of size...
            m.i.j=originalgray(i:(i+24), j:(j+38)); % create sub images sub regions of size...
                double_m=double(m.i.j);
%                 double_m=double_m(:); % columnize block
%          The local mean, ?_L, of all pixel values in a block below a
%          threshold, ?, tow_t is computed.

                Lvar = var(double_m(double_m <  220));
                Lmean =  mean(double_m(double_m <  220));
    %             Lvar = var(double_m(double_m <  Dependent_mean + 0.1* Dependent_mean));

            if Lvar <=  G_var_low && Lmean <= G_mean_low % Condition 1: Either full dark ridges or thick ridges or smudged ridges
%                if Lmean < G_mean_low/2
%                Binarized_m = m.i.j >  round(Lmean * 0.7);
%                else
               Binarized_m = m.i.j >  round(Lmean);    
%                end
               
            elseif Lvar <=  G_var_low && Lmean > G_mean_low  && Lmean < G_mean_high % Condition 2: Either normal colour ridges or few ridges
                   if Lmean < G_Bin_T
                   Binarized_m = m.i.j >  round(G_Bin_T * 0.95);    
                   else
                   Binarized_m = m.i.j >  round(G_Bin_T * 1.05);
                   end
            elseif Lvar <=  G_var_low && Lmean >= G_mean_high % Condition 3: Clear or spotty Background 
                
                    if Lvar < 60
                    Binarized_m = m.i.j > round(G_Bin_T); % This binarizes the block 
                    else
                    Binarized_m = m.i.j > round(1.15*G_Bin_T); % This binarizes the block                        
                    end
                
            elseif Lvar >  G_var_low && Lvar <  G_var_high && Lmean <= G_mean_low  % Condition 4: Dark colour ridges and some light background
               Binarized_m = m.i.j >  round(G_Bin_T * 1.05); 
               
            elseif Lvar >  G_var_low && Lvar <  G_var_high && Lmean > G_mean_low  && Lmean < G_mean_high  % Condition 5: Good normal ridges or contains equal dark & light pixels
               Binarized_m = m.i.j >  round(Lmean * 1.05); 
               
            elseif Lvar >  G_var_low && Lvar <  G_var_high && Lmean >= G_mean_high  % Condition 6: Spaced ridges
               Binarized_m = m.i.j >  round(Lmean * 1.06); 
              
            elseif Lvar >  G_var_high && Lmean <= G_mean_low   % Condition 7: 
               Binarized_m = m.i.j >  round(Lmean * 0.95);
               
            elseif Lvar >  G_var_high && Lmean > G_mean_low  && Lmean < G_mean_high   % Condition 8: 
               Binarized_m = m.i.j >  round(Lmean * 1.1);
            
            else % condition 9: few dark pixels (sparce)in background
               Binarized_m = m.i.j >  round(G_Bin_T * 1.01); 
            end


            k =[k, Binarized_m]; % Group a number of sub-regions into a row structure
        end
        r = [r;k]; % Group the rows into cols and rows structure

    end
end   
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

binarizeImage = r;