FROM kasmweb/core-nvidia-focal:develop-rolling

USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
WORKDIR $HOME

######### START CUSTOMIZATION ########

# install apt packages
RUN apt-get update && apt-get install -y \
        python3-pip libasound2 libegl1-mesa libgl1-mesa-glx \
        libxcomposite1 libxcursor1 libxi6 libxrandr2 libxss1 \
        libxtst6 gdal-bin ffmpeg vlc dnsutils iputils-ping \
        git remmina remmina-plugin-rdp

# update pip and install python packages
COPY resources/install_python_packages.sh /tmp/
RUN bash /tmp/install_python_packages.sh

# Install Anaconda3
COPY resources/install_anaconda.sh /tmp/
RUN bash /tmp/install_anaconda.sh

# Install packages in conda environment
USER 1000
COPY resources/install_conda_packages.sh /tmp/
RUN bash /tmp/install_conda_packages.sh
USER root 

# Install nvtop
COPY resources/install_nvtop.sh /tmp/
RUN bash /tmp/install_nvtop.sh

# QGIS
COPY resources/install_qgis.sh /tmp/
RUN bash /tmp/install_qgis.sh

# Create desktop shortcuts
COPY resources/spyder.desktop $HOME/Desktop/
COPY resources/jupyter.desktop $HOME/Desktop/
COPY resources/pycharm.desktop ${HOME}/Desktop/
RUN cp /usr/share/applications/org.remmina.Remmina.desktop $HOME/Desktop/ \
    && chmod +x $HOME/Desktop/org.remmina.Remmina.desktop \
    && chown 1000:1000 $HOME/Desktop/org.remmina.Remmina.desktop

RUN pip install jupyterlab jupyter_http_over_ws

RUN jupyter serverextension enable --py jupyter_http_over_ws

RUN jupyter notebook \
  --NotebookApp.allow_origin='https://colab.research.google.com' \
  --port=8888 \
  --NotebookApp.port_retries=0

######### END CUSTOMIZATIONS ########

RUN chown -R 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

CMD ["--tail-log"]
