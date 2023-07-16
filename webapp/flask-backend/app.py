from flask import Flask, jsonify, request
from logger import create_logger
from flask_cors import CORS, cross_origin
from PIL import Image
from werkzeug.utils import secure_filename
import os
import base64
import io
import subprocess
from utils import TemporaryWorkingDirectory, cleanup_all, resize_image
from apscheduler.schedulers.background import BackgroundScheduler
from postprocess import generate_series

app = Flask(__name__)
CORS(app)

# ENV_FILE is an environment variable that points to the environment file, e.g. development.py
app.config.from_envvar('ENV_FILE')

scheduler = BackgroundScheduler(daemon=True)
scheduler.add_job(lambda: cleanup_all(app.config["IMAGES_TMP_DIR"], interval_secs=15 * 60), 'interval', minutes=15)
scheduler.start()

logger = create_logger(
    __name__,
    f'{app.config["LOGS_DIR"]}/flask_server.log',
)


@app.route("/health", methods=["GET"])
@cross_origin()
def index():
    return jsonify({"message": "hello, world"})


@app.route('/upload', methods=['POST'])
@app.route('/api/upload', methods=['POST'])
@cross_origin()
def upload_image():
    with TemporaryWorkingDirectory(app.config["IMAGES_TMP_DIR"]) as (upload_dir, dir_hash):
        logger.info(f"Directory hash: {dir_hash}")

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

            image = resize_image(image)

            # Save the image to the unique directory
            filename = secure_filename(f'{key}.bmp')
            image.save(os.path.join(upload_dir, 'test', filename))

        try:
            logger.info(f"running model inference for {dir_hash}")
            # Run the first shell command
            result = subprocess.run(
                [f'{app.config["CONDA_ENV_ROOT"]}/bin/python',
                 f'{app.config["PROJECT_DIR"]}/src/gpu/pytorch_pix2pix_test.py',
                 '--dataset', upload_dir, '--model_path', app.config["MODEL_PATH"], '--gpu_num', "1"],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                check=True)

            if result.returncode == 0:
                logger.info(result.stdout.decode('utf-8'))
            else:
                logger.error(result.stderr.decode('utf-8'))
            logger.info(f"model inference completed for {dir_hash}")

            logger.info(f"running postprocessing for {dir_hash}")
            # Run the second shell command with a specified current working directory
            generate_series(
                f'{app.config["IMAGES_TMP_DIR"]}/uploaded_{dir_hash}_results/test_results',
                f'{app.config["IMAGES_TMP_DIR"]}/uploaded_{dir_hash}_generate_series_results',
                f'{app.config["PROJECT_DIR"]}/src/eval/Rapid_Colormap.mat',
            )
            logger.info(f"postprocessing completed for {dir_hash}")
        except subprocess.CalledProcessError as e:
            logger.error(e.output.decode('utf-8'))
            # If the subprocess returned an error, return a HTTP 500 response
            return jsonify({"message": "Internal Server Error"}), 500
        except Exception as e:
            logger.error(e)
            return jsonify({"message": "Internal Server Error"}), 500

        for i in range(len(request.form.keys())):
            # Image path
            img_path = f'{app.config["IMAGES_TMP_DIR"]}/uploaded_{dir_hash}_generate_series_results/fake/image{i}_Simulated.png'

            # Open the image file in binary mode, read it, and base64 encode its contents
            with open(img_path, 'rb') as f:
                img_data = f.read()
            img_str = base64.b64encode(img_data).decode()

            base64_images.append(f"data:image/png;base64,{img_str}")

        return jsonify({"images": base64_images})


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5001)
