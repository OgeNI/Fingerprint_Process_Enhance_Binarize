import numpy as np


def binarize_FVC560(grayimage):
    # Get Global mean, and variance of dark pixels in preprocessed image.
    originalgray = grayimage
    gray_img_columnized = originalgray.flatten().astype(float)
    dark_pixels = gray_img_columnized[gray_img_columnized < 170]
    mean_dark_pixels = np.mean(dark_pixels)
    Var_dark_pixels = np.var(dark_pixels)

    # Format image size first
    rows_image, cols_image = originalgray.shape

    # Binarization starts here
    G_var = Var_dark_pixels  # Global variance set
    G_Bin_T = mean_dark_pixels  # global binarization threshold set

    # The normal range will be between the low and high values for the variance and mean
    G_var_low = G_var * 0.6
    G_var_high = G_var * 1.4
    G_mean_low = G_Bin_T * 0.85
    G_mean_high = G_Bin_T * 1.15

    # TYPE I
    if mean_dark_pixels < 140 and Var_dark_pixels < 2000:
        # Global approach is used then for binarization
        r = originalgray < (mean_dark_pixels + 0.04 * mean_dark_pixels)
    else:
        # TYPE II
        # Divide image into blocks
        r = np.zeros_like(originalgray, dtype=bool)

        for i in range(0, rows_image, int(rows_image / 14)):
            k = []
            for j in range(0, cols_image, int(cols_image / 16)):
                sub_img = originalgray[i : i + 26, j : j + 16]
                double_m = sub_img.astype(float)
                local_dark_pixels = double_m[double_m < 170]
                Lvar = np.var(local_dark_pixels)
                Lmean = np.mean(local_dark_pixels)

                if Lvar <= G_var_low and Lmean <= G_mean_low:
                    Binarized_m = sub_img > np.round(Lmean)
                elif Lvar <= G_var_low and G_mean_low < Lmean < G_mean_high:
                    if Lmean < G_Bin_T:
                        Binarized_m = sub_img > np.round(G_Bin_T * 0.95)
                    else:
                        Binarized_m = sub_img > np.round(G_Bin_T * 1.05)
                elif Lvar <= G_var_low and Lmean >= G_mean_high:
                    if Lvar < 60:
                        Binarized_m = sub_img > np.round(G_Bin_T)
                    else:
                        Binarized_m = sub_img > np.round(1.15 * G_Bin_T)
                elif G_var_low < Lvar < G_var_high and Lmean <= G_mean_low:
                    Binarized_m = sub_img > np.round(G_Bin_T * 1.05)
                elif G_var_low < Lvar < G_var_high and G_mean_low < Lmean < G_mean_high:
                    Binarized_m = sub_img > np.round(Lmean * 1.05)
                elif G_var_low < Lvar < G_var_high and Lmean >= G_mean_high:
                    Binarized_m = sub_img > np.round(Lmean * 1.06)
                elif Lvar > G_var_high and Lmean <= G_mean_low:
                    Binarized_m = sub_img > np.round(Lmean * 0.95)
                elif Lvar > G_var_high and G_mean_low < Lmean < G_mean_high:
                    Binarized_m = sub_img > np.round(Lmean * 1.1)
                else:  # condition 9
                    Binarized_m = sub_img > np.round(G_Bin_T * 1.01)

                k.append(Binarized_m)
            r[i : i + 26, :] = np.hstack(k)

    return r.astype(np.uint8) * 255


# Example usage:
# gray_image = np.array([[...]], dtype=np.uint8)  # Example grayscale image
# binarized_image = binarize_FVC560(gray_image)
