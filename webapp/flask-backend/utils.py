import hashlib
import os
import random
import shutil
import threading
import time
from PIL import Image


def cleanup(tmp_dir, dir_hash):
    time.sleep(600)  # wait for 10 minutes

    dir_path = f'{tmp_dir}/uploaded_{dir_hash}'
    result_dir_path = f'{tmp_dir}/uploaded_{dir_hash}_results'
    generate_series_dir_path = f'{tmp_dir}/uploaded_{dir_hash}_generate_series_results'

    shutil.rmtree(dir_path, ignore_errors=True)
    shutil.rmtree(result_dir_path, ignore_errors=True)
    shutil.rmtree(generate_series_dir_path, ignore_errors=True)


def cleanup_all(tmp_dir):
    for dir_name in os.listdir(tmp_dir):
        if dir_name.startswith("uploaded_"):
            dir_path = os.path.join(tmp_dir, dir_name)
            shutil.rmtree(dir_path, ignore_errors=True)


class TemporaryWorkingDirectory:
    """
    A context manager that creates a hashed temporary working directory and clean up 10 minutes after use.

    Usage:
    with TemporaryWorkingDirectory() as (upload_dir, dir_hash):
        # do something with the upload_dir

    temporary working directories clean up by this context manager:
    - {tmp_dir}/uploaded_{dir_hash}
    - {tmp_dir}/uploaded_{dir_hash}_results
    - {tmp_dir}/uploaded_{dir_hash}_generate_series_results
    """

    def __init__(self, tmp_dir):
        self.tmp_dir = tmp_dir
        # Get current timestamp and a random number
        current_time = str(time.time())
        random_num = str(random.randint(1, 1e6))

        # Combine the timestamp and random number, and generate a hash
        hash_input = (current_time + random_num).encode('utf-8')
        self.dir_hash = hashlib.md5(hash_input).hexdigest()

    def __enter__(self):
        # create hashed directory
        upload_dir = f'{self.tmp_dir}/uploaded_{self.dir_hash}'
        os.makedirs(f"{upload_dir}/test", exist_ok=True)
        return upload_dir, self.dir_hash

    def __exit__(self, type, value, traceback):
        # Schedule cleanup
        cleanup_thread = threading.Thread(target=cleanup, args=(self.tmp_dir, self.dir_hash,))
        cleanup_thread.start()


def resize_image(img):
    """
    The MAGIC model expects an input image of size 256x256. The reason being, each convolution layer with kernel size
    4x4 and stride 2 is halving the dimensions of the image, and the eighth convolution layer (self.conv8_1) expects an
    input of size 4x4.

    This function takes an image of any size, and returns an image of size 256x256. The returned image is a 256x256
    image with the original image pasted in the top left corner. The rest of the image is black.
    """
    # Resize the image to 256x256
    img = img.resize((256, 256))

    # 2. Generate another image of size 256x256 with black background
    # Create a new blank image with width five times that of the resized image and the same height.
    img_full = Image.new('RGB', (256 * 5, 256), 'black')

    # Paste the resized image into the new image
    img_full.paste(img, (0, 0))

    # Create a black blank image of the same size as the original image
    black_img = Image.new('RGB', (256, 256), 'black')

    # Paste the black images into the new image
    img_full.paste(black_img, (256, 0))
    img_full.paste(black_img, (256 * 2, 0))
    img_full.paste(black_img, (256 * 3, 0))
    img_full.paste(black_img, (256 * 4, 0))

    return img_full
