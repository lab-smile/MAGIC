# MAGIC Web Interface

## Local Development

### Run the frontend locally

The frontend is written using React. In the project directory, you can run:

### `npm start`

The React app will run at [http://localhost:3000](http://localhost:3000)

The page will reload when you make changes.\
You may also see any lint errors in the console.

### Run the backend locally

The backend is written in Python Flask web framework. Before running the backend server you need to create
virtualenv.yaml file

#### create virtualenv locally

1. Install virtualenvwrapper

```bash
pip install virtualenvwrapper
```

2. Add the following to `~/.bashrc`

```bash
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python3
source /opt/homebrew/bin/virtualenvwrapper.sh
```

3. Create a new virtual environment

```bash
mkvirtualenv magic-flask
```

4. Install required dependencies in virtualenv

```bash
workon magic-flask
pip install -r requirements.txt
```

### Start Flask server

```bash
python app.py
```

## Production Deployment

### Compile MATLAB

This step use mcc to package and deploy MATLAB program (standalone_generated_series.m) as standalone applications. 
Run the following commands to compile the MATLAB program on HiperGator.

```
mkdir -p compile_generate_series && cd compile_generate_series

module load matlab

mcc -R -singleCompThread -m generate_series.m
```

### 
