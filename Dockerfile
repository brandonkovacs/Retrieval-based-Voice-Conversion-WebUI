FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04
EXPOSE 7865

# Copy files to /app
COPY . /app
WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y -qq ffmpeg aria2 && apt clean && \
    apt-get install -y software-properties-common curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install conda
RUN curl -o ~/miniconda.sh -O  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
      chmod +x ~/miniconda.sh && \
      ~/miniconda.sh -b -p /opt/conda && \
      rm ~/miniconda.sh

# Add conda to path
ENV PATH /opt/conda/bin:$PATH

# Install base conda environment with cuda support
RUN conda tos accept && conda config --set always_yes yes --set changeps1 no && conda update -q conda

# Upgrade pip and install remaining dependencies
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128
RUN python3 -m pip install --no-cache-dir -r requirements-py311.txt

RUN python3 tools/download_models.py

VOLUME [ "/app/weights", "/app/opt" ]

CMD ["python3", "infer-web.py"]
