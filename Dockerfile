FROM public.ecr.aws/lambda/python:3.8

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN yum -y update && yum -y install mesa-libGL

RUN pip install -r requirements.txt

ENV TRANSFORMERS_CACHE /dev/null
ENV HF_HOME /dev/null

COPY demo.py ${LAMBDA_TASK_ROOT}
COPY stable_diffusion_engine.py ${LAMBDA_TASK_ROOT}

CMD [ "demo.handler" ]