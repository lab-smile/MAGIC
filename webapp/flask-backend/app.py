import io
import base64

from flask_cors import CORS, cross_origin
from flask import Flask, request, jsonify
from PIL import Image, ImageOps

app = Flask(__name__)
CORS(app)


@app.route("/health", methods=["GET"])
@cross_origin()
def index():
    return jsonify({"message": "hello, world"})


@app.route('/api/upload', methods=['POST'])
@cross_origin()
def upload_image():
    # Get the image from the request
    image_data_str = request.form['image'].split(",")
    if len(image_data_str) < 2:
        return jsonify({"message": "Invalid image"}), 400
    # Open the image with PIL
    img_data = image_data_str[1].encode("utf-8")
    img_binary_data = io.BytesIO(base64.decodebytes(img_data))
    image = Image.open(img_binary_data)
    # Invert the colors of the image
    inverted_image = ImageOps.invert(image.convert('RGB'))
    images = [inverted_image] * 4

    base64_images = []
    for img in images:
        buffered = io.BytesIO()
        img.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode()
        base64_images.append(f"data:image/png;base64,{img_str}")

    return jsonify({"images": base64_images})


if __name__ == '__main__':
    app.run(debug=True, port=5001)
