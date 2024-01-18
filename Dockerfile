FROM public.ecr.aws/lambda/python:3.9 as builder
RUN yum -y update && yum -y install gcc make gcc-c++ zlib-devel bison bison-devel gzip glibc-static wget tar git
RUN wget https://ftp.gnu.org/gnu/glibc/glibc-2.27.tar.gz && tar zxvf glibc-2.27.tar.gz && rm glibc-2.27.tar.gz && mv ./glibc-2.27/ /opt/glibc-2.27/
RUN wget https://github.com/git-lfs/git-lfs/releases/download/v2.13.3/git-lfs-linux-amd64-v2.13.3.tar.gz && \
    tar -zxvf git-lfs-linux-amd64-v2.13.3.tar.gz && \
    sh ./install.sh && \
    rm -rf git-lfs-2.13.3 git-lfs-linux-amd64-v2.13.3.tar.gz
RUN git lfs install && git clone https://huggingface.co/bes-dev/stable-diffusion-v1-4-openvino
ENV GIT_LFS_SKIP_SMUDGE=1
RUN git clone https://huggingface.co/openai/clip-vit-large-patch14
WORKDIR /opt/glibc-2.27/build
RUN /opt/glibc-2.27/configure --prefix=/var/task && make && make install

FROM centos:7 as openvino
RUN yum -y update && yum -y install epel-release gcc gcc-c++ make cmake python3 python3-pip glibc-static libstdc++-static libstdc++-devel glibc-devel wget tar git which
RUN mkdir /opt/intel
RUN cd /opt/intel && \
    curl -L https://storage.openvinotoolkit.org/repositories/openvino/packages/2022.3.1/linux/l_openvino_toolkit_centos7_2022.3.1.9227.cf2c7da5689_x86_64.tgz --output openvino_2022.3.1.tgz && \
    tar -xf openvino_2022.3.1.tgz && \
    mv l_openvino_toolkit_centos7_2022.3.1.9227.cf2c7da5689_x86_64 openvino_2022.3.1
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    cd /opt/intel/openvino_2022.3.1 && \
    yes | ./install_dependencies/install_openvino_dependencies.sh

FROM public.ecr.aws/lambda/python:3.9 as production
COPY requirements.txt  ./
RUN pip install -r requirements.txt
RUN yum -y update && yum -y install mesa-libGL
# model
COPY --from=builder \
    /var/task/stable-diffusion-v1-4-openvino/text_encoder.bin \
    /var/task/stable-diffusion-v1-4-openvino/text_encoder.xml \
    /var/task/stable-diffusion-v1-4-openvino/unet.bin \
    /var/task/stable-diffusion-v1-4-openvino/unet.xml \
    /var/task/stable-diffusion-v1-4-openvino/vae_decoder.bin \
    /var/task/stable-diffusion-v1-4-openvino/vae_decoder.xml \
    /var/task/stable-diffusion-v1-4-openvino/vae_encoder.bin \
    /var/task/stable-diffusion-v1-4-openvino/vae_encoder.xml /var/task/model/
# tokenizer
COPY --from=builder \
    /var/task/clip-vit-large-patch14/tokenizer_config.json \
    /var/task/clip-vit-large-patch14/vocab.json \
    /var/task/clip-vit-large-patch14/merges.txt \
    /var/task/clip-vit-large-patch14/special_tokens_map.json \
    /var/task/clip-vit-large-patch14/tokenizer.json /var/task/tokenizer/

COPY --from=openvino /opt/intel/openvino_2022.3.1/runtime/lib/intel64/* /var/task/
COPY --from=openvino /opt/intel/openvino_2022.3.1/runtime/3rdparty/tbb/lib/* /var/task/
COPY --from=openvino /opt/intel/openvino_2022.3.1/python/python3.9/ /var/task/python3.9/
COPY --from=builder /var/task/lib/libm.so.6 /lib64/

COPY app.py ./
COPY stable_diffusion_engine.py ./
CMD [ "app.handler" ]