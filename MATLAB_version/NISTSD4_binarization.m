function binarizeImage = NISTSD4_binarization(originalgray,Var_dark_pixels,mean_dark_pixels,minimum_dark_pixels)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get global mean and variance of the image
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% gray_img_columnized =  double(originalgray(:));
% mean_gray = mean(gray_img_columnized);
% var_gray = Var_dark_pixels;
% -------------------------------------------------------------------------
G_var = Var_dark_pixels; % Global variance set

G_Bin_T = mean_dark_pixels; % global binarization threshold set

% Set thresholds for variance and mean - low and high 
% The normal range will be between the low and high values for the variance
% and mean
G_var_low = G_var*0.6; % G_var - 0.4 of G_var
G_var_high = G_var*1.4; % G_var + 0.4 of G_var
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
G_mean_low = G_Bin_T*0.85; % G_Bin_T - 0.15 of G_Bin_T
G_mean_high = G_Bin_T*1.15; % G_Bin_T + 0.15 of G_Bin_T
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Format image size first
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rows_image=size(originalgray,1);
    cols_image=size(originalgray,2);
%     Since the image may have been cropeed to an unknown size, better make
%     it a standard size before binarizing in sub images.
%  Set the added space to the lightest pixel value in the original image.  
max_pixel=max(originalgray(:));
        if rows_image < 512
            originalgray(rows_image+1:512,:)=max_pixel;
        end
        if cols_image < 480
        originalgray(:,cols_image+1:480)=max_pixel;
        end
    % the image rows and columns.
    rows_image=size(originalgray,1);
    cols_image=size(originalgray,2);
%      done

% -------------------------------------------------------------------------
%  Binarization starts here
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if mean_dark_pixels < 85 && Var_dark_pixels < 400 && minimum_dark_pixels < 20 % Global approach is used then for binarization
    r = originalgray < (mean_dark_pixels + 0.04 * mean_dark_pixels);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
elseif Var_dark_pixels < 150 % i.e. variance is very low, hence image is very light with high mean, 
    % and with high minimum pixel automatically. Then use careful binarization here
    
%          Dependent_mean = mean_dark_pixels + 0.08*mean_dark_pixels;
        % Perform this in the horizontal direction
    r=[]; 
    for i = 1:rows_image % step in 1 down the image rows
    %     for i = 1:4:rows_image % step in 4 down the image rows
        k=[];
        for j= 1:160:cols_image % step in 31 over the image columns
    %         m.i.j=originalgray(i:(i+3), j:(j+95)); % create sub images , vectors,(sub regions) of size...
            m.i.j=originalgray(i, j:(j+159)); % create sub images , vectors,(sub regions) of size...
            % 1 by 31 at each step. Remember the steps increase by 31 in
            % columns
    % %        Get the local mean and local variance called Lmean & Lvar
    % respectively.
                double_m=double(m.i.j);
%                 double_m=double_m(:);


                Lvar = var(double_m(double_m <  180));
                Lmean =  mean(double_m(double_m <  180));
                
            if Lvar <= G_var/2 && Lmean > G_Bin_T
    %             
                    Binarized_m = m.i.j > round(G_Bin_T); % This binarizes the block when the print is dark
                
            elseif Lvar < G_var*2/3 && Lvar > G_var/2 > G_Bin_T
    %
                Binarized_m = m.i.j > round(G_Bin_T*1.05); % This binarizes the block when the print is dark
                
            else 
                Binarized_m = m.i.j > round(1.15*G_Bin_T); % This binarizes the block 
                    
            end

            k =[k, Binarized_m]; % Group a number of sub-regions into a row structure
        end
        r = [r;k]; % Group the rows into cols and rows structure

    end
    
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
else 
     
%     Last condition holds here
%      Anyting greater than the global mean plus 4% of the mean should not
%      be a ridge, call this value the Dependent_mean
%     Dependent_mean = mean_dark_pixels + 0.04*mean_dark_pixels;
    % Perform this in the horizontal direction
    r=[]; 
%     for i = 1:rows_image % step in 4 down the image rows
     for i = 1:8:rows_image % step in 8 down the image rows
    %     
        k=[];
        for j= 1:80:cols_image % step in 80 over the image columns
%             m.i.j=originalgray(i, j:(j+39)); % create sub images ,sub regions of size...
            m.i.j=originalgray(i:(i+7), j:(j+79)); % create sub images ,sub regions of size...
            % 8 by 239 at each step. Remember the steps increase by 80 in
            % columns
    % %        Get the local mean and local variance called Lmean & Lvar
    % respectively.
                double_m=double(m.i.j);
                double_m=double_m(:);

                Lvar = var(double_m(double_m <  180));
                Lmean =  mean(double_m(double_m <  180));
    %             Lvar = var(double_m(double_m <  Dependent_mean + 0.1* Dependent_mean));

            if Lmean <= G_mean_low && Lvar <=  G_var_low  % Condition 1: smudged ridges
                   if Lmean <= (G_Bin_T*0.6)
                   Binarized_m = m.i.j >  round(Lmean * 0.9);
                   elseif Lmean > (G_Bin_T*0.6) && Lmean < (G_Bin_T*0.75)
                   Binarized_m = m.i.j >  round(Lmean);    
                   else
                   Binarized_m = m.i.j >  round(Lmean*1.05);    
                   end
                    
            elseif Lmean <= G_mean_low && Lvar >  G_var_low && Lvar <  G_var_high % Condition 2: Dark colour ridges 
                   
                   if Lmean <= (G_Bin_T*0.6)
                   Binarized_m = m.i.j >  round(Lmean * 0.85);
                   elseif Lmean > (G_Bin_T*0.6) && Lmean < (G_Bin_T*0.75)
                   Binarized_m = m.i.j >  round(Lmean * 1.02);    
                   else
                   Binarized_m = m.i.j >  round(Lmean*1.03);    
                   end
                
            elseif Lmean <= G_mean_low && Lvar >  G_var_high % Condition 3:  
                   if Lmean <= (G_Bin_T*0.6)
                   Binarized_m = m.i.j >  round(Lmean * 0.7);
                   elseif Lmean > (G_Bin_T*0.6) && Lmean < (G_Bin_T*0.75)
                   Binarized_m = m.i.j >  round(Lmean * 0.8);    
                   else
                   Binarized_m = m.i.j >  round(Lmean*0.9);    
                   end
%                     Binarized_m = m.i.j > round(1.1*Lmean); % This binarizes the block                        
                            
            elseif Lmean > G_mean_low  && Lmean < G_mean_high && Lvar <=  G_var_low   % Condition 4: some Dark colour ridges and some light background
               
                   if Lvar < 150
                   Binarized_m = m.i.j > round(G_Bin_T*1.22);    
                   elseif Lmean <= (G_Bin_T)
                   Binarized_m = m.i.j >  round(Lmean * 0.95);                  
                   else
%                    Binarized_m = m.i.j >  round(G_Bin_T * 1.01);
                   Binarized_m = m.i.j >  round(Lmean*1.05); 
%                    Binarized_m = m.i.j >  round(G_Bin_T * 1.05); 
                   end
                
              
            elseif Lmean > G_mean_low  && Lmean < G_mean_high && Lvar >  G_var_low && Lvar <=  G_var_high   % Condition 5: Good normal ridges or contains equla dark & light pixels
%                Binarized_m = m.i.j >  round(Lmean * 1.08);
                   if Lmean <= (G_Bin_T)
                   Binarized_m = m.i.j >  round(Lmean * 0.95);                  
                   else
%                    Binarized_m = m.i.j >  round(Lmean*1.07);    
                   Binarized_m = m.i.j >  round(G_Bin_T * 1.01);
                   end
                
%                Binarized_m = m.i.j >  round(G_Bin_T * 1.12);
               
            elseif Lmean > G_mean_low  && Lmean < G_mean_high && Lvar > G_var_high   % Condition 6: Spaced ridges
%                Binarized_m = m.i.j >  round(Lmean * 1.20); 
                    if Lmean <= (G_Bin_T*1.1)
                   Binarized_m = m.i.j >  round(Lmean * 1.08);                  
                   else
                   Binarized_m = m.i.j >  round(G_Bin_T*1.03); 
%                    Binarized_m = m.i.j >  round(G_Bin_T*1.1);
                   end

%               Binarized_m = m.i.j >  round(G_Bin_T * 1.09);
            elseif Lmean >= G_mean_high && Lvar <=  G_var_low   % Condition 7: 
                    if Lvar < 200 % Lvar < 40
                    Binarized_m = m.i.j > round(G_Bin_T*1.20); % This binarizes the block
%                     Binarized_m = m.i.j > round(G_Bin_T*1.05); 
                    else
%                     Binarized_m = m.i.j > round(1.11*Lmean); % This binarizes the block (it worked lastly) 
                    Binarized_m = m.i.j > round(G_Bin_T*1.11); % This binarizes the block 
                    end
               
            elseif Lmean >= G_mean_high && Lvar >  G_var_low && Lvar <=  G_var_high   % Condition 8: 
                if Lvar < (G_var * 1.1)
                Binarized_m = m.i.j >  round(Lmean * 1.12);
                else
                Binarized_m = m.i.j >  round(G_Bin_T * 1.05);    
                end
            
            else % condition 9: few dark pixels (sparce)in background
                if Lmean <= (G_Bin_T*1.2)
                Binarized_m = m.i.j >  round(G_Bin_T * 1.02);
                else
                Binarized_m = m.i.j >  round(G_Bin_T * 1.03);    
                end
%                Binarized_m = m.i.j >  round(G_Bin_T * 1.15); 
            end

            k =[k, Binarized_m]; % Group a number of sub-regions into a row structure
        end
        r = [r;k]; % Group the rows into cols and rows structure

    end    
 end
binarizeImage = r;
end