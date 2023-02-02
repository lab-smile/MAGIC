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
COPY src /src
WORKDIR /src/gpu
RUN conda config --set channel_priority strict
RUN conda env create -f magic_env.yml
RUN conda-pack -n py3-2 -o /tmp/env.tar && \
    mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
    rm /tmp/env.tar
RUN /venv/bin/conda-unpack

FROM nvidia/cuda:11.7.1-devel-ubuntu20.04 AS RUNTIME
COPY --from=BUILD_CONDA_ENV /venv /venv
COPY src /src
WORKDIR /src/gpu
CMD ["/bin/bash", "-c", "source /venv/bin/activate && python pytorch_pix2pix.py --dataset '../sample' --lrG 0.00005 --lrD 0.00005 --train_epoch 50 --save_root 'results'"]
