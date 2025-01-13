import numpy as np
import NISTSD4_binarization

# -------------------------------------------------------------------------
# Step 1: filter out outliers below pixel value of Glowlimit. They are obviously
# not ridges. Check image for such pixels and replace with 255, this is
# done in the first part of the if ... else loop below.
# Filter out outliers in image and replace those pixels with pixel value
# 250, mask the resulting image with the original image. The first part of
# the if ... else loop applies this generally to the image to pixels values
# less than Glowlimit.
# Or, Filter out outliers of the same pixel value as  ridges in the image.
# Note that ridges are characterized by undulating pixel values like
# [68,72,84,81, 116,123,111, 131, 126, 79, 81, 76, 85 ...] while marks and
# prints or scars are typically characterized by short groups of dark
# pixels in the midst of lighter pixels (if scars are not embedded in
# ridges). Once the group is spotted, the first part of the if ... else
# loop removes them and replaces the pixels with 255.
# These pixels are replace along the horizontal and vertical directions in
# the image and image is combined as one at the end.
# if no such pixels exist, then the scars of marks if present may be
# embedded in ridges, so the reasonable thing to do is to crop the image at
# that point. the next part of the if ... else loop does that.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def binarize_nistsd4_challenging(grayimage):
    originalgray = grayimage.copy()

    # STEP 1
    gray_img_columnized = originalgray.flatten().astype(float)
    mean_dark_pixels = np.mean(gray_img_columnized[gray_img_columnized < 180])
    var_dark_pixels = np.var(gray_img_columnized[gray_img_columnized < 180])

    Gsorted = np.sort(gray_img_columnized)
    minimum_dark_pixels = round(np.mean(Gsorted[:500]))

    if mean_dark_pixels >= 85 and minimum_dark_pixels < 20:
        Glowlimit = 20  # Assuming Glowest is defined as 0
        originalgray[originalgray < Glowlimit] = 255  # masked
        if mean_dark_pixels < 95:
            originalgray[originalgray < 25] = 255  # masked
        else:
            originalgray[originalgray < 30] = 255  # masked

    sum255vert = np.sum(originalgray == 255, axis=0)
    sum255hort = np.sum(originalgray == 255, axis=1)

    vertfind = np.where(sum255vert > 200)[0]
    hortfind = np.where(sum255hort > 200)[0]

    vertlimit = 1 if vertfind.size == 0 else np.max(vertfind)
    hortlimit = 1 if hortfind.size == 0 else np.max(hortfind)

    originalgray = originalgray[hortlimit:, vertlimit:]

    rows_image, cols_image = originalgray.shape
    m_threshold = 140
    r = []

    for i in range(rows_image):
        k = []
        for j in range(0, cols_image, 8):
            m_i_j = originalgray[i, j : j + 60]

            if np.sum(m_i_j < m_threshold) < 25:
                find_m = np.where(m_i_j < m_threshold)[0]
                indexmlow = np.min(find_m)
                indexmhigh = np.max(find_m)
                span_m = indexmhigh - indexmlow

                if 5 < span_m < 15:
                    m_i_j[m_i_j < m_threshold] = 255

            k.append(m_i_j)

        r.append(np.concatenate(k))

    m_threshold = 160
    w_threshold = 130
    o = []

    for j in range(cols_image):
        p = []
        for i in range(0, rows_image, 10):
            w_j_i = originalgray[i : i + 51, j]

            if np.sum(w_j_i < m_threshold) < 30:
                find_m = np.where(w_j_i < m_threshold)[0]
                length_find_m = find_m.size
                find_non = np.where(w_j_i >= m_threshold)[0]
                length_find_non = find_non.size
                shift_findm = np.roll(find_m, 1)
                span_find = np.abs(find_m - shift_findm)
                find_w = np.where(w_j_i < w_threshold)[0]
                shift_findw = np.roll(find_w, 1)
                span_findw = np.abs(find_w - shift_findw)

                if (
                    (span_find > 1).sum() <= 3
                    and length_find_non > 30
                    and length_find_m > 6
                ):
                    w_j_i[w_j_i < m_threshold] = 255
                elif (span_find > 1).sum() <= 1 and 15 < length_find_m < 22:
                    w_j_i[w_j_i < m_threshold] = 255
                elif (
                    (span_findw > 1).sum() <= 1 and find_w.size > 5 and find_w.size < 50
                ):
                    w_j_i[w_j_i < w_threshold] = 255

            p.append(w_j_i)

        o.append(np.vstack(p))

    HVcomb = np.maximum(np.array(r), np.array(o))
    originalgray = HVcomb

    sum255vert = np.sum(originalgray == 255, axis=0)
    sum255hort = np.sum(originalgray == 255, axis=1)

    vertfind = np.where(sum255vert > 200)[0]
    hortfind = np.where(sum255hort > 200)[0]

    vertlimit = 1 if vertfind.size == 0 else np.max(vertfind)
    hortlimit = 1 if hortfind.size == 0 else np.max(hortfind)

    originalgray = originalgray[hortlimit:, vertlimit:]

    # STEP 2
    binarizeIm = NISTSD4_binarization(
        originalgray, var_dark_pixels, mean_dark_pixels, minimum_dark_pixels
    )
    return binarizeIm
