import logging
import sys

import numpy as np
from flask import current_app
from matplotlib.colors import ListedColormap
from matplotlib.pyplot import imread
from scipy.io import loadmat
from skimage.color import rgb2gray
import matplotlib.pyplot as plt
import os
from logger import create_logger

try:
    logger = create_logger(
        __name__,
        f'{current_app.config["LOGS_DIR"]}/flask_server.log',
    )
except RuntimeError as e:
    # If this module is imported outside of flask context, e.g. in a script, then use the default logger to write to
    # stdout.
    logger = logging.getLogger(__name__)
    stdout_handler = logging.StreamHandler(sys.stdout)
    logger.addHandler(stdout_handler)
    logger.setLevel(logging.INFO)


def rgb2gray(rgb):
    """
    Convert RGB image to grayscale using the same coefficients as MATLAB's rgb2gray
    """
    return np.dot(rgb[..., :3], [0.2989, 0.5870, 0.1140])


def process_fake_file(fake_dir, fake_filename, fake_outpath, colormap):
    """
    postprocessing of single image after image generation from model inference.
    :param fake_dir: directory of fake images
    :param fake_filename: filename of the image to be processed under fake_dir
    :param fake_outpath: directory to save the processed image
    :param colormap: colormap to use for the image
    """
    imgpath = os.path.join(fake_dir, fake_filename)
    logger.info(f'Processing {imgpath}...')

    # Use imread to load the image
    img = imread(imgpath)

    height, width = img.shape[:2]
    unit = width // 4

    img = img[..., :3]

    # Convert the image to grayscale
    imgA = rgb2gray(img[:, 0:unit])
    imgB = rgb2gray(img[:, unit:2 * unit])
    imgC = rgb2gray(img[:, 2 * unit:3 * unit])
    imgD = rgb2gray(img[:, 3 * unit:4 * unit])

    # Convert the image's numpy array of floats to a numpy array of unsigned integers that's same as
    # what MATLAB's imread would return
    imgA = (imgA * 255).round().astype(np.uint8)
    imgB = (imgB * 255).round().astype(np.uint8)
    imgC = (imgC * 255).round().astype(np.uint8)
    imgD = (imgD * 255).round().astype(np.uint8)

    fig, axs = plt.subplots(2, 2)

    # By specifying vmin=0 and vmax=256, we're telling imshow to map the colormap so that 0 is mapped to the lowest
    # color in the colormap and 256 is mapped to the highest color in the colormap.
    #
    # If vmin and/or vmax are not provided, imshow will use the minimum and maximum values in the data (in our case,
    # the image array) to map the colormap. In other words, the lowest value in imgA/B/C/D data will correspond to the
    # lowest color in the colormap and the highest value in imgA/B/C/D will correspond to the highest color in the
    # colormap.
    axs[0, 0].imshow(imgA, cmap=colormap, vmin=0, vmax=255)
    axs[0, 0].title.set_text('MTT')

    axs[0, 1].imshow(imgB, cmap=colormap, vmin=0, vmax=255)
    axs[0, 1].title.set_text('TTP')

    axs[1, 0].imshow(imgC, cmap=colormap, vmin=0, vmax=255)
    axs[1, 0].title.set_text('CBF')

    axs[1, 1].imshow(imgD, cmap=colormap, vmin=0, vmax=255)
    axs[1, 1].title.set_text('CBV')

    for ax in axs.flat:
        ax.set_axis_off()

    savename = fake_filename.replace('_output', '').split('.')[0]
    imgtitle = f'{savename}_Simulated'
    fig.suptitle(imgtitle)

    save_path = os.path.join(fake_outpath, f'{imgtitle}.png')
    logger.info(f'Saving to {save_path}...')
    plt.savefig(save_path, dpi=1024)
    plt.close(fig)


def generate_series(datapath_fake, outpath, colormap_path):
    """
    postprocessing after images generation from model inference.
    This is a Python rewrite of the MATLAB script src/eval/generate_series.m

    example:

        generate_series(
            "/Users/yufeng/Desktop/test_images/uploaded_e1245b5465434a05eb1be48041df2cf8_results/test_results",
            "/Users/yufeng/Desktop/test_images/uploaded_e1245b5465434a05eb1be48041df2cf8_generate_series_results_3",
            "/Users/yufeng/research/smile/MAGIC/src/eval/Rapid_Colormap.mat"
        )

    :param datapath_fake: path to the directory containing the fake images, expecing png images under this directory
    :param outpath: path to the directory to save the processed images. The processed images will be saved under the
    subdirectory 'fake' under this directory
    :param colormap_path: path to the colormap file
    """
    logger.info(f"Postprocessing {datapath_fake} using colormap at {colormap_path}...")
    datapath_fake = os.path.abspath(datapath_fake)
    fake_outpath = os.path.join(os.path.abspath(outpath), 'fake')

    os.makedirs(fake_outpath, exist_ok=True)

    data = loadmat(colormap_path)
    Rapid_U = data['Rapid_U']
    cmap_Rapid_U = ListedColormap(Rapid_U, 'Rapid_U')

    # Process fake files
    for fake_filename in os.listdir(datapath_fake):
        if fake_filename.endswith('.png'):
            process_fake_file(datapath_fake, fake_filename, fake_outpath, cmap_Rapid_U)

    logger.info(f"Postprocessing {datapath_fake} using colormap at {colormap_path}...Done!")

# generate_series(
#     "/Users/yufeng/Desktop/test_images/uploaded_e1245b5465434a05eb1be48041df2cf8_results/test_results",
#     "/Users/yufeng/Desktop/test_images/uploaded_e1245b5465434a05eb1be48041df2cf8_generate_series_results_4",
#     "/Users/yufeng/research/smile/MAGIC/src/eval/Rapid_Colormap.mat"
# )
