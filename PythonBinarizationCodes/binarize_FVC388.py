import numpy as np


def binarize_FVC388(grayimage):
    originalgray = grayimage.copy()

    # Get Global mean, and variance of dark pixels in preprocessed image.
    gray_img_columnized = originalgray.flatten().astype(float)
    mean_dark_pixels = np.mean(gray_img_columnized[gray_img_columnized < 220])
    var_dark_pixels = np.var(gray_img_columnized[gray_img_columnized < 220])

    # Format image size first
    rows_image, cols_image = originalgray.shape

    # Binarization starts here

    # Image is 375 x 390. divide by 15 and 10 respectively.
    G_var = var_dark_pixels  # Global variance set
    G_Bin_T = mean_dark_pixels  # Global binarization threshold set

    # Set thresholds for variance and mean
    # % The normal range will be between the low and high values for the variance and mean
    G_var_low = G_var * 0.6  # G_var - 0.4 of G_var
    G_var_high = G_var * 1.4  # G_var + 0.4 of G_var
    G_mean_low = G_Bin_T * 0.85  # G_Bin_T - 0.15 of G_Bin_T
    G_mean_high = G_Bin_T * 1.15  # G_Bin_T + 0.15 of G_Bin_T

    # TYPE I
    if (
        mean_dark_pixels < 170 and var_dark_pixels < 2000
    ):  # Global approach is used then for binarization
        r = originalgray < (mean_dark_pixels + 0.04 * mean_dark_pixels)
    else:
        # TYPE II
        r = []
        for i in range(0, rows_image, 15):  # step in 15 down the image rows
            k = []
            for j in range(0, cols_image, 10):  # step in 10 over the image columns
                m_ij = originalgray[
                    i : i + 25, j : j + 39
                ]  # create sub images sub regions of size...
                double_m = m_ij.astype(float)

                # The local mean and variance of all pixel values in a block below a threshold
                Lvar = np.var(double_m[double_m < 220])
                Lmean = np.mean(double_m[double_m < 220])

                if (
                    Lvar <= G_var_low and Lmean <= G_mean_low
                ):  # Condition 1: Either full dark ridges or thick ridges or smudged ridges
                    Binarized_m = m_ij > round(Lmean)
                elif (
                    Lvar <= G_var_low and G_mean_low < Lmean < G_mean_high
                ):  # Condition 2: Either normal colour ridges or few ridges
                    if Lmean < G_Bin_T:
                        Binarized_m = m_ij > round(G_Bin_T * 0.95)
                    else:
                        Binarized_m = m_ij > round(G_Bin_T * 1.05)
                elif (
                    Lvar <= G_var_low and Lmean >= G_mean_high
                ):  # Condition 3: Clear or spotty Background
                    if Lvar < 60:
                        Binarized_m = m_ij > round(G_Bin_T)
                    else:
                        Binarized_m = m_ij > round(1.15 * G_Bin_T)
                elif (
                    G_var_low < Lvar < G_var_high and Lmean <= G_mean_low
                ):  # Condition 4: Dark colour ridges and some light background
                    Binarized_m = m_ij > round(G_Bin_T * 1.05)
                elif (
                    G_var_low < Lvar < G_var_high and G_mean_low < Lmean < G_mean_high
                ):  # Condition 5Good normal ridges or contains equal dark & light pixels
                    Binarized_m = m_ij > round(Lmean * 1.05)
                elif (
                    G_var_low < Lvar < G_var_high and Lmean >= G_mean_high
                ):  # Condition 6: Spaced ridges
                    Binarized_m = m_ij > round(Lmean * 1.06)
                elif Lvar > G_var_high and Lmean <= G_mean_low:  # Condition 7
                    Binarized_m = m_ij > round(Lmean * 0.95)
                elif (
                    Lvar > G_var_high and G_mean_low < Lmean < G_mean_high
                ):  # Condition 8
                    Binarized_m = m_ij > round(Lmean * 1.1)
                else:  # Condition 9: few dark pixels (sparce)in background
                    Binarized_m = m_ij > round(G_Bin_T * 1.01)

                k.append(
                    Binarized_m
                )  # Group a number of sub-regions into a row structure

            r.append(
                np.concatenate(k, axis=1)
            )  # Group the rows into cols and rows structure

    return np.array(r)
