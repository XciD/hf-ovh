# HF Pipeline API

The purpose of this api is to classify the polarity of any text with a hugging face sentiment analysis pipeline.
The business use case behind this api is to classify some tweet about the OVHcloud IPO.

# Language / Framework 

We will use python for the main language, as the hf pipeline is already in python.
For the API framework we could use flask, or bottle, but after some search, I decided to implement it through BentoML as it already pack various feature, like micro-batching

# Build

Requirements:
- python 3.x

```
make TAG=v1
```