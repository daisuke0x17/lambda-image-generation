# -- coding: utf-8 --`
import argparse
import gc
import json
import os
import random
# engine
from stable_diffusion_engine import StableDiffusionEngine
# scheduler
from diffusers import LMSDiscreteScheduler, PNDMScheduler
# utils
import cv2
import numpy as np
from openvino.runtime import Core

os.environ['HUGGINGFACE_CACHE'] = '/tmp/cache/huggingface'

DEFAULT_SEED = None
DEFAULT_INIT_IMAGE = None
DEFAULT_BETA_START = 0.00085
DEFAULT_BETA_END = 0.012
DEFAULT_BETA_SCHEDULE = "scaled_linear"
DEFAULT_MODEL = "bes-dev/stable-diffusion-v1-4-openvino"
DEFAULT_TOKENIZER = "openai/clip-vit-large-patch14"
DEFAULT_DEVICE = "CPU"
DEFAULT_PROMPT = "a photograph of an astronaut riding a horse"
DEFAULT_MASK = None
DEFAULT_STRENGTH = 0.5
DEFAULT_NUM_INFERENCE_STEPS = 32
DEFAULT_GUIDANCE_SCALE = 7.5
DEFAULT_ETA = 0.0
DEFAULT_OUTPUT = "output.png"

def handler(event, context):
    gc.collect()
    seed = event.setdefault('seed', DEFAULT_SEED)
    if seed is None:
        seed = random.randint(0, 2**30)
    np.random.seed(seed)
    if event.setdefault('init_image', DEFAULT_INIT_IMAGE) is None:
        scheduler = LMSDiscreteScheduler(
            beta_start=event.setdefault('beta_start', DEFAULT_BETA_START),
            beta_end=event.setdefault('beta_end', DEFAULT_BETA_END),
            beta_schedule=event.setdefault('beta_schedule', DEFAULT_BETA_SCHEDULE),
            tensor_format="np"
        )
    else:
        scheduler = PNDMScheduler(
            beta_start=event.setdefault('beta_start', DEFAULT_BETA_START),
            beta_end=event.setdefault('beta_end', DEFAULT_BETA_END),
            beta_schedule=event.setdefault('beta_schedule', DEFAULT_BETA_SCHEDULE),
            skip_prk_steps = True,
            tensor_format="np"
        )
    engine = StableDiffusionEngine(
        # model=event.setdefault('model', DEFAULT_MODEL),
        scheduler=scheduler,
        # tokenizer=event.setdefault('tokenizer', DEFAULT_TOKENIZER),
        device=event.setdefault('device', DEFAULT_DEVICE),
    )
    image = engine(
        prompt = event.setdefault('prompt', DEFAULT_PROMPT),
        init_image = None if event.setdefault('init_image', DEFAULT_INIT_IMAGE) is None else cv2.imread('/tmp/' + event.setdefault('init_image', DEFAULT_INIT_IMAGE)),
        mask = None if event.setdefault('mask', DEFAULT_MASK) is None else cv2.imread('/tmp/' + event.setdefault('mask', DEFAULT_MASK), 0),
        strength = event.setdefault('strength', DEFAULT_STRENGTH),
        num_inference_steps = event.setdefault('num_inference_steps', DEFAULT_NUM_INFERENCE_STEPS),
        guidance_scale = event.setdefault('guidance_scale', DEFAULT_GUIDANCE_SCALE),
        eta = event.setdefault('eta', DEFAULT_ETA)
    )
    cv2.imwrite('/tmp/' + event.setdefault('output', DEFAULT_OUTPUT), image)
    gc.collect()
    return  {"statusCode": 200, "body": { "seed":seed, "prompt": event.setdefault('prompt', DEFAULT_PROMPT) }}