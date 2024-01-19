FROM public.ecr.aws/lambda/python:3.8 as builder
RUN yum -y update && yum -y install gcc make gcc-c++ zlib-devel bison bison-devel gzip glibc-static wget tar git && \
    rm -rf /var/cache/yum/* \
    yum clean all
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

FROM public.ecr.aws/lambda/python:3.8
COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN yum -y update && yum -y install mesa-libGL && \
    rm -rf /var/cache/yum/* && \
    yum clean all
RUN pip install -U pip &&\
    pip install --no-cache-dir -r requirements.txt
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
ENV TRANSFORMERS_CACHE /tmp/cache/transformers
ENV HF_HOME /tmp/cache/huggingface
COPY app.py ${LAMBDA_TASK_ROOT}
COPY stable_diffusion_engine.py ${LAMBDA_TASK_ROOT}

CMD [ "app.handler" ]