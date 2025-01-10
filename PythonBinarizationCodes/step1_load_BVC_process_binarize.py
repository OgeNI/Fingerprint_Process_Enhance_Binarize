import os
import time
from skimage import io
import numpy as np
import binarize_FVC560
import binarize_FVC388

# Paths for reading and saving images
dpathimread = ""
dpathsaveimg1 = "\\"
dpathsaveimg2 = "\\"

# Reading all .tif files
filenames = [f for f in os.listdir(dpathimread) if f.endswith(".tif")]
num_of_imgs = len(filenames)

start_time = time.time()

for i in range(num_of_imgs):
    grayimage = io.imread(os.path.join(dpathimread, filenames[i]), as_gray=True)

    if grayimage.shape[0] == 560:  # for e.g. FVC db2 2000, 560 X 296
        binarize_image = binarize_FVC560(grayimage)
        newname = filenames[i]
        newfile = os.path.join(dpathsaveimg1, newname + ".bmp")
        io.imsave(newfile, binarize_image, plugin="pil", format_str="bmp")
    else:  # FVC db1 2002 with non-uniform fingerprints' sizes of 388 x 374
        # Resize 388 x 374 to 390 x 375 by setting extra pixels to 255
        padded_image = np.pad(
            grayimage, ((0, 15), (0, 2)), "constant", constant_values=255
        )
        binarize_image = binarize_FVC388(padded_image)
        newname = filenames[i]
        newfile = os.path.join(dpathsaveimg2, newname + ".bmp")
        io.imsave(newfile, binarize_image, plugin="pil", format_str="bmp")

    print({i, newname})

end_time = time.time()
print("Elapsed time: {:.2f} seconds".format(end_time - start_time))
