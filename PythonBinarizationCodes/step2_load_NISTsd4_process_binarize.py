import os
import time
import cv2
import numpy as np
import binarize_nistsd4_straightforward


# Load NIST images (assuming filenames and Num_of_imgs are defined)
# This is a placeholder for loading the images. You need to implement this based on your data source.
def load_nist_images():
    # Example structure for filenames and Num_of_imgs
    # Replace this with actual loading logic
    filenames = [{"name": f"image_{i}.png"} for i in range(1, 41)]  # Example filenames
    Num_of_imgs = len(filenames)
    return filenames, Num_of_imgs


def main():
    dpathimread = r"path_to_load_images"  # Path to load images
    dpathsaveimg = r"path_to_save_images"  # Path to save images

    # Load images
    filenames, Num_of_imgs = load_nist_images()

    start_time = time.time()

    for i in range(Num_of_imgs):  # Loop through images
        grayimage = cv2.imread(
            os.path.join(dpathimread, filenames[i]["name"]), cv2.IMREAD_GRAYSCALE
        )

        # Remove the last two rows if the image is 512 pixels in height
        if grayimage.shape[0] == 512:
            grayimage = grayimage[:-2, :]

        binarizeImage = binarize_nistsd4_straightforward(grayimage)

        newname = filenames[i]["name"]
        newfile = os.path.join(dpathsaveimg, f"{newname}.bmp")

        cv2.imwrite(newfile, binarizeImage)

    elapsed_time = time.time() - start_time
    print(f"Elapsed time is {elapsed_time:.2f} seconds")


if __name__ == "__main__":
    main()
