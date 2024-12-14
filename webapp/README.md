# MAGIC Web Interface

## Local Development

### Run the frontend locally

The frontend is written using React. In the webapp directory, you can run:

`npm start`

The React app will run at [http://localhost:3000](http://localhost:3000)

The page will reload when you make changes.\
You may also see any lint errors in the console.

Alternatively, you can run the frontend in a Docker container. In the webapp/docker directory, you can run:
```bash
docker-compose build frontend
docker-compose up frontend
```

The frontend will run at [http://localhost:3000](http://localhost:3000)

Note: 
- In either case, you will need to update the webapp/.env file to point to the backend server. Currently it's set to 
the production server running on HiperGator web hosting server.
- You will need to install the latest docker-compose to run the frontend in a Docker container.

### Run the backend locally

The backend is written in Python Flask web framework. You can run the backend locally in docker container using 
docker-compose. Before running the backend locally, you will need to:
- Have model file under src/ (e.g. src/MAGIC_Generator_FINAL.pkl)
- Install latest version of docker-compose
- Install Nvidia Container Toolkit (https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

In the webapp/docker directory, you can run:

```bash
docker-compose build backend
docker-compose up backend
````

## Production Deployment

The following instruction is for deploying the web application on HiperGator web hosting server (https://www.rc.ufl.edu/services/hipergator-web-hosting/).
Frontend and backend running on HiperGator web hosting server runs on bare metal host and are deployed as Docker containers.

### Clone or update the Git repository

```bash
git clone git@github.com:lab-smile/MAGIC.git
pushd MAGIC
git co -b magic-webapp
git br -u origin/magic-webapp magic-webapp
git pull
``` 

### Start frontend

```bash
pushd webapp
npm install
npm run start
```

### Start backend

```bash
pushd webapp/flask-backend
pip install -r requirements.txt
supervisord -c magic-webapp.conf
```