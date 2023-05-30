from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
from PIL import Image, ImageOps
from werkzeug.utils import secure_filename
import os
import base64
import hashlib
import io
import subprocess
import time
import random
import logging
import shutil
import threading

# Configure logging
logging.basicConfig(level=logging.INFO)

app = Flask(__name__)
CORS(app)


@app.route("/health", methods=["GET"])
@cross_origin()
def index():
    return jsonify({"message": "hello, world"})


def cleanup(dir_hash):
    time.sleep(600)  # wait for 10 minutes

    dir_path = f"/var/tmp/uploaded_{dir_hash}"
    result_dir_path = f"/var/tmp/uploaded_{dir_hash}_results"
    generate_series_dir_path = f"/var/tmp/uploaded_{dir_hash}_generate_series_results"

    shutil.rmtree(dir_path, ignore_errors=True)
    shutil.rmtree(result_dir_path, ignore_errors=True)
    shutil.rmtree(generate_series_dir_path, ignore_errors=True)


@app.route('/api/upload', methods=['POST'])
@cross_origin()
def upload_image():
    base64_images = []
    for key in request.form.keys():
        # Get the image
        image_data_str = request.form[key].split(",")
        if len(image_data_str) < 2:
            return jsonify({"message": "Invalid image"}), 400

        # Open the image with PIL
        img_data = image_data_str[1].encode("utf-8")
        img_binary_data = io.BytesIO(base64.decodebytes(img_data))
        image = Image.open(img_binary_data)

        # Get current timestamp and a random number
        current_time = str(time.time())
        random_num = str(random.randint(1, 1e6))

        # Combine the timestamp and random number, and generate a hash
        hash_input = (current_time + random_num).encode('utf-8')
        dir_hash = hashlib.md5(hash_input).hexdigest()

        logging.info(f"Directory hash: {dir_hash}")

        upload_dir = f"/var/tmp/uploaded_{dir_hash}"
        os.makedirs(f"{upload_dir}/test", exist_ok=True)

        # Save the image to the unique directory
        filename = secure_filename('uploaded_image.bmp')
        image.save(os.path.join(upload_dir, 'test', filename))

        try:
            # Run the first shell command
            subprocess.run(
                ['/home/ubuntu/.conda/envs/magic_env/bin/python', '/home/ubuntu/MAGIC/src/gpu/pytorch_pix2pix_test.py',
                 '--dataset', upload_dir, '--model_path', '/home/ubuntu/MAGIC/src/MAGIC_Generator_FINAL.pkl'],
                check=True)

            # Run the second shell command with a specified current working directory
            subprocess.run(
                ['./run_generate_series.sh', '/usr/local/MATLAB/MATLAB_Runtime/R2023a/', f"{upload_dir}/test",
                 f"/var/tmp/uploaded_{dir_hash}_results/test_results",
                 f"/var/tmp/uploaded_{dir_hash}_generate_series_results",
                 '/home/ubuntu/MAGIC/src/eval/Rapid_Colormap.mat'], check=True,
                cwd='/home/ubuntu/compile_generate_series')
        except subprocess.CalledProcessError:
            # If the subprocess returned an error, return a HTTP 500 response
            return jsonify({"message": "Internal Server Error"}), 500

        # Schedule cleanup
        cleanup_thread = threading.Thread(target=cleanup, args=(dir_hash,))
        cleanup_thread.start()

        # Image path
        img_path = f"/var/tmp/uploaded_{dir_hash}_generate_series_results/real/uploaded_image_Real.png"

        # Open the image file in binary mode, read it, and base64 encode its contents
        with open(img_path, 'rb') as f:
            img_data = f.read()
        img_str = base64.b64encode(img_data).decode()

        base64_images.append(f"data:image/png;base64,{img_str}")

    return jsonify({"images": base64_images})


if __name__ == '__main__':
    app.run(debug=True, port=5001)
