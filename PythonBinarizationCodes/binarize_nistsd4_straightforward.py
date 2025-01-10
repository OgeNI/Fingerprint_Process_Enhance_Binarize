import numpy as np


def binarize_nistsd4_straightforward(grayimage):
    """
    Binarizes a grayscale image using a two-step process:
    Step 1: Removes scars and marks from NIST images.
    Step 2: Performs local binarization in lines of 51 for an image of size 510 by 480.

    Parameters:
    grayimage (numpy.ndarray): The input grayscale image.

    Returns:
    numpy.ndarray: The binarized image.
    """

    # Step 1: Remove Scars
    originalgray = grayimage.astype(np.float64)

    # Get global mean, minimum and variance of dark pixels
    gray_img_columnized = originalgray.flatten()
    mean_dark_pixels = np.mean(gray_img_columnized[gray_img_columnized < 180])
    var_dark_pixels = np.var(gray_img_columnized[gray_img_columnized < 180])

    # Determine lowest pixel values from the average value of 500 darkest pixels
    Gsorted = np.sort(gray_img_columnized)
    minimum_dark_pixels = round(np.mean(Gsorted[:500]))

    # Step 2: Binarization using a placeholder function NISTSD4_binarization
    binaImage = NISTSD4_binarization(
        originalgray, var_dark_pixels, mean_dark_pixels, minimum_dark_pixels
    )

    return binaImage
