FROM ubuntu:18.04 AS CONDA_INSTALLER_DOWNLOAD
ARG CONDA_INSTALLER=Anaconda3-2022.10-Linux-x86_64.sh
RUN apt-get update &&  \
    apt-get install -y wget && \
    wget -O /conda.sh "https://repo.anaconda.com/archive/${CONDA_INSTALLER}"

FROM ubuntu:18.04 AS CONDA_INSTALL
COPY --from=CONDA_INSTALLER_DOWNLOAD /conda.sh /conda.sh
RUN ["/bin/bash", "-c", "chmod a+x /conda.sh && /conda.sh -b -p /usr/local/conda"]

FROM nvidia/cuda:11.7.1-devel-ubuntu20.04 AS BUILD_CONDA_ENV
COPY --from=CONDA_INSTALL /usr/local/conda /usr/local/conda
ENV PATH /usr/local/conda/bin:$PATH
RUN echo "channels:\n  - defaults\n  - conda-forge" > ~/.condarc
COPY /src/hpg /hpg
WORKDIR /hpg
RUN conda env create -f magic_env.yml

FROM nvidia/cuda:11.7.1-devel-ubuntu20.04 AS BUILD_PIP_ENV
COPY /webapp/flask-backend/requirements.txt /magic-webapp-backend/requirements.txt
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata python3.10 python3-pip python3-venv zlib1g-dev libjpeg-dev
RUN python3 -m venv /magic-web-backend-venv
RUN /bin/bash -c "source /magic-web-backend-venv/bin/activate && pip install -r /magic-webapp-backend/requirements.txt"

FROM nvidia/cuda:11.7.1-devel-ubuntu20.04 AS RUNTIME
COPY /src /src
COPY /webapp/flask-backend /magic-webapp-backend
COPY --from=BUILD_CONDA_ENV /usr/local/conda/envs/magic_env /venv
COPY --from=BUILD_PIP_ENV /magic-web-backend-venv /magic-web-backend-venv
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3.10
RUN mkdir -p /magic-webapp-backend/logs; mkdir -p /magic-webapp-backend/tmp
WORKDIR /magic-webapp-backend
ENV ENV_FILE=development.py
CMD ["/magic-web-backend-venv/bin/gunicorn", "-c", "gunicorn_config.py", "app:app"]