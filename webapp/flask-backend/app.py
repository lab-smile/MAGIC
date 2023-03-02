import base64

from flask import Flask, request, jsonify
from PIL import Image, ImageOps
import io
from flask_cors import CORS, cross_origin

app = Flask(__name__)
CORS(app)


@app.route("/health", methods=["GET"])
@cross_origin()
def index():
    return jsonify({"message": "hello, world"})


@app.route('/convert', methods=['POST'])
@cross_origin()
def convert_image():
    # Get the image from the request
    image_data_str = request.form['image']
    # Open the image with PIL
    img_data = image_data_str.split(",")[1].encode("utf-8")
    img_binary_data = io.BytesIO(base64.decodebytes(img_data))
    image = Image.open(img_binary_data)
    # Invert the colors of the image
    inverted_image = ImageOps.invert(image.convert('RGB'))
    # Save the output image to a buffer
    output_buffer = io.BytesIO()
    inverted_image.save(output_buffer, format='PNG')
    # Return the output image
    inverted_image_encoded = base64.b64encode(output_buffer.getvalue()).decode('utf-8')
    return jsonify({'image': f"data:image/png;base64,{inverted_image_encoded}"})


if __name__ == '__main__':
    app.run(debug=True, port=5001)
