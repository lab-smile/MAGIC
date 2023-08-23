import React, {useState, useCallback} from 'react';
import axios from 'axios';
import {Controlled as ControlledZoom} from 'react-medium-image-zoom';
import 'react-medium-image-zoom/dist/styles.css';
import './App.css';
import logo from './static/smile-lab-logo.png';

function App() {
  const [images, setImages] = useState(null);
  const [responseImages, setResponseImages] = useState([]);
  const [zoomIndex, setZoomIndex] = useState(-1);
  const [zoomInnerIndex, setZoomInnerIndex] = useState(-1);
  const [uploadedImageZoomed, setUploadedImageZoomed] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleImageChange = (e) => {
    const files = Array.from(e.target.files);
    const readers = files.map(file => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      return new Promise((resolve, reject) => {
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
      });
    });

    Promise.all(readers).then(setImages);
  };

  const handleImageClick = useCallback((outerIndex, innerIndex) => {
    if (zoomIndex === outerIndex && zoomInnerIndex === innerIndex) {
      setZoomIndex(-1);
      setZoomInnerIndex(-1);
    } else {
      setZoomIndex(outerIndex);
      setZoomInnerIndex(innerIndex);
    }
  }, [zoomIndex, zoomInnerIndex]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formData = new FormData();
    images.forEach((image, i) => {
      formData.append(`image${i}`, image);
    });

    const baseUrl = process.env.REACT_APP_API_BASE_URL;

    setIsLoading(true); // set loading state to true

    try {
      const response = await axios.post(`${baseUrl}/api/upload`, formData);

      setResponseImages(response.data.images);
      setError(null);
    } catch (error) {
      console.error(error);
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        console.log(error.response.data);
        console.log(error.response.status);
        console.log(error.response.headers);
        setError(`Error while uploading image: ${error.response.status}`);
      } else if (error.request) {
        // The request was made but no response was received
        console.log(error.request);
        setError(`Error while uploading image: No response from server.`);
      } else {
        // Something happened in setting up the request that triggered an Error
        console.log('Error', error.message);
        setError(`Error while uploading image: ${error.message}`);
      }

    } finally {
      setIsLoading(false); // set loading state to false, whether the request succeeded or failed
    }
  };

  // Other code...

  return (
      <div className="App">
        <div className="header">
          <img src={logo} alt="Logo" className="app-logo"/>
          <div className="header-text">
            MAGIC: Multitask, Automated Generation of Intermodal CT Perfusion Maps via Generative Adversarial Networks
          </div>
        </div>
        <div className="content">
          {isLoading ? (
              <div className="loader"/> // show a loading spinner while waiting for the response
          ) : (
              <form onSubmit={handleSubmit}>
                <input type="file" multiple onChange={handleImageChange}/>
                <button type="submit">Upload Image</button>
              </form>
          )}
          {error && <div className="error">{error}</div>}
          {images && images.map((image, i) => (
              <div className="row" key={`row${i}`}>
                <div className="column">
                  <div
                      className="uploaded-image-container"
                      onClick={() => setUploadedImageZoomed(i !== uploadedImageZoomed ? i : -1)}
                  >
                    <ControlledZoom
                        isZoomed={uploadedImageZoomed === i}
                        onZoomChange={(isZoomed) => !isZoomed && setUploadedImageZoomed(-1)}
                        zoomMargin={10}
                    >
                      <img src={image} alt={`Uploaded ${i + 1}`} className="uploaded-image"/>
                    </ControlledZoom>
                  </div>
                </div>
                {responseImages[i] && responseImages[i].map((responseImage, j) => (
                    <div className="column" key={`response${j}`}>
                      <div className="response-image-container" onClick={() => handleImageClick(i, j)}>
                        <ControlledZoom
                            isZoomed={zoomIndex === i && zoomInnerIndex === j}
                            onZoomChange={(isZoomed) => !isZoomed && (setZoomIndex(-1), setZoomInnerIndex(-1))}
                            zoomMargin={10}
                        >
                          <img src={responseImage} alt={`Response ${i + 1}`} className="response-image"/>
                        </ControlledZoom>
                      </div>
                    </div>
                ))}
              </div>
          ))}
        </div>
      </div>
  );
}

export default App;

