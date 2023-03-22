import React, {useState, useCallback} from 'react';
import axios from 'axios';
import {Controlled as ControlledZoom} from 'react-medium-image-zoom';
import 'react-medium-image-zoom/dist/styles.css';
import './App.css';
import logo from './static/smile-lab-logo.png';

function App() {
  const [image, setImage] = useState(null);
  const [responseImages, setResponseImages] = useState([]);
  const [zoomIndex, setZoomIndex] = useState(-1);
  const [uploadedImageZoomed, setUploadedImageZoomed] = useState(false);

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      setImage(reader.result);
    };
  };

  const handleImageClick = useCallback((index) => {
    if (zoomIndex === index) {
      setZoomIndex(-1);
    } else {
      setZoomIndex(index);
    }
  }, [zoomIndex]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formData = new FormData();
    formData.append('image', image);

    try {
      const response = await axios.post('http://localhost:5001/api/upload', formData);

      setResponseImages(response.data.images);
    } catch (error) {
      console.error('Error while uploading image:', error);
    }
  };

  return (
      <div className="App">
        <div className="header">
          <img src={logo} alt="Logo" className="app-logo"/>
          <div className="header-text">
            MAGIC: Multitask, Automated Generation of Intermodal CT Perfusion Maps via Generative Adversarial Networks
          </div>
        </div>
        <div className="content">
          <div className="left-side">
            <form onSubmit={handleSubmit}>
              <input type="file" onChange={handleImageChange}/>
              <button type="submit">Upload Image</button>
            </form>
            {image && (
                <div
                    className="uploaded-image-container"
                    onClick={() => setUploadedImageZoomed(!uploadedImageZoomed)}
                >
                  <ControlledZoom
                      isZoomed={uploadedImageZoomed}
                      onZoomChange={(isZoomed) => !isZoomed && setUploadedImageZoomed(false)}
                      zoomMargin={10}
                  >
                    <img src={image} alt="Uploaded" className="uploaded-image"/>
                  </ControlledZoom>
                </div>
            )}
          </div>
          <div className="right-side">
            {responseImages.map((src, index) => (
                <div key={index} onClick={() => handleImageClick(index)}>
                  <ControlledZoom
                      isZoomed={zoomIndex === index}
                      onZoomChange={(isZoomed) => !isZoomed && setZoomIndex(-1)}
                      zoomMargin={10}
                  >
                    <img src={src} alt={`Response ${index + 1}`} className="response-image"/>
                  </ControlledZoom>
                </div>
            ))}
          </div>
        </div>
      </div>
  );
}

export default App;
