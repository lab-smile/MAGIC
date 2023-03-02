import React, {useState} from 'react';
import axios from 'axios';
import Dropzone from 'react-dropzone';

function App() {
  const [inputImage, setInputImage] = useState(null);
  const [outputImage, setOutputImage] = useState(null);

  const handleImageDrop = (acceptedFiles) => {
    const reader = new FileReader();
    reader.readAsDataURL(acceptedFiles[0]);
    reader.onload = () => {
      setInputImage(reader.result);
    };
  };

  const handleImageUpload = () => {
    const formData = new FormData();
    formData.append('image', inputImage);
    axios.post('http://localhost:5001/convert', formData)
        .then(response => {
          console.log(response.data.image)
          setOutputImage(response.data.image);
        })
        .catch(error => {
          console.log(error);
        });
  };

  return (
      <div className="App">
        <div className="image-container">
          <h2>Input Image</h2>
          <Dropzone onDrop={handleImageDrop}>
            {({getRootProps, getInputProps}) => (
                <div {...getRootProps()}>
                  <input {...getInputProps()} />
                  <p>Drag and drop an image file here, or click to select a file</p>
                </div>
            )}
          </Dropzone>
          {inputImage && (
              <div>
                <img src={inputImage} alt="Input" />
                <button onClick={handleImageUpload}>Convert</button>
              </div>
          )}
        </div>
        <div className="image-container">
          <h2>Output Image</h2>
          {outputImage && (
              <img src={outputImage} alt="Output" />
          )}
        </div>
      </div>
  );
}

export default App;