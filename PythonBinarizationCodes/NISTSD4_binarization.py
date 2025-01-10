import numpy as np


def NISTSD4_binarization(origImg, Var_dark_pixels, mean_dp, min_dark_pixs):
    G_var = Var_dark_pixels
    G_Bin_T = mean_dp

    GvarL = G_var * 0.6
    GvarH = G_var * 1.4

    GavL = G_Bin_T * 0.85
    GavH = G_Bin_T * 1.15

    Rimg, cols_image = origImg.shape
    max_pixel = np.max(origImg)

    if Rimg < 512:
        origImg = np.pad(
            origImg, ((0, 512 - Rimg), (0, 0)), "constant", constant_values=max_pixel
        )
    if cols_image < 480:
        origImg = np.pad(
            origImg,
            ((0, 0), (0, 480 - cols_image)),
            "constant",
            constant_values=max_pixel,
        )

    Rimg, cols_image = origImg.shape

    if mean_dp < 85 and Var_dark_pixels < 400 and min_dark_pixs < 20:
        r = origImg < (mean_dp + 0.04 * mean_dp)
    elif Var_dark_pixels < 150:
        r = []
        for i in range(Rimg):
            k = []
            for j in range(0, cols_image, 160):
                m_ij = origImg[i, j : j + 160]
                dm = m_ij.astype(float)

                Lvar = np.var(dm[dm < 180])
                Lmean = np.mean(dm[dm < 180])

                if Lvar <= G_var / 2 and Lmean > G_Bin_T:
                    BM = m_ij > round(G_Bin_T)
                elif Lvar < G_var * 2 / 3 and Lvar > G_var / 2 > G_Bin_T:
                    BM = m_ij > round(G_Bin_T * 1.05)
                else:
                    BM = m_ij > round(1.15 * G_Bin_T)

                k.extend(BM)
            r.append(k)
        r = np.array(r)
    else:
        r = []
        for i in range(0, Rimg, 8):
            k = []
            for j in range(0, cols_image, 80):
                m_ij = origImg[i : i + 8, j : j + 80]
                dm = m_ij.astype(float).flatten()

                Lvar = np.var(dm[dm < 180])
                Lmean = np.mean(dm[dm < 180])

                if Lmean <= GavL and Lvar <= GvarL:
                    if Lmean <= (G_Bin_T * 0.6):
                        BM = m_ij > round(Lmean * 0.9)
                    elif Lmean > (G_Bin_T * 0.6) and Lmean < (G_Bin_T * 0.75):
                        BM = m_ij > round(Lmean)
                    else:
                        BM = m_ij > round(Lmean * 1.05)
                elif Lmean <= GavL and GvarL < Lvar < GvarH:
                    if Lmean <= (G_Bin_T * 0.6):
                        BM = m_ij > round(Lmean * 0.85)
                    elif Lmean > (G_Bin_T * 0.6) and Lmean < (G_Bin_T * 0.75):
                        BM = m_ij > round(Lmean * 1.02)
                    else:
                        BM = m_ij > round(Lmean * 1.03)
                elif Lmean <= GavL and Lvar > GvarH:
                    if Lmean <= (G_Bin_T * 0.6):
                        BM = m_ij > round(Lmean * 0.7)
                    elif Lmean > (G_Bin_T * 0.6) and Lmean < (G_Bin_T * 0.75):
                        BM = m_ij > round(Lmean * 0.8)
                    else:
                        BM = m_ij > round(Lmean * 0.9)
                elif GavL < Lmean < GavH and Lvar <= GvarL:
                    if Lvar < 150:
                        BM = m_ij > round(G_Bin_T * 1.22)
                    elif Lmean <= G_Bin_T:
                        BM = m_ij > round(Lmean * 0.95)
                    else:
                        BM = m_ij > round(Lmean * 1.05)
                elif GavL < Lmean < GavH and GvarL < Lvar <= GvarH:
                    if Lmean <= G_Bin_T:
                        BM = m_ij > round(Lmean * 0.95)
                    else:
                        BM = m_ij > round(G_Bin_T * 1.01)
                elif GavL < Lmean < GavH and Lvar > GvarH:
                    if Lmean <= (G_Bin_T * 1.1):
                        BM = m_ij > round(Lmean * 1.08)
                    else:
                        BM = m_ij > round(G_Bin_T * 1.03)
                elif Lmean >= GavH and Lvar <= GvarL:
                    if Lvar < 200:
                        BM = m_ij > round(G_Bin_T * 1.20)
                    else:
                        BM = m_ij > round(G_Bin_T * 1.11)
                elif Lmean >= GavH and GvarL < Lvar <= GvarH:
                    if Lvar < (G_var * 1.1):
                        BM = m_ij > round(Lmean * 1.12)
                    else:
                        BM = m_ij > round(G_Bin_T * 1.05)
                else:
                    if Lmean <= (G_Bin_T * 1.2):
                        BM = m_ij > round(G_Bin_T * 1.02)
                    else:
                        BM = m_ij > round(G_Bin_T * 1.03)

                k.extend(BM)
            r.append(k)
        r = np.array(r)

    return r
