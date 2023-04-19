# ChadGPT

<img src="https://static.wikia.nocookie.net/virgin-vs-chad/images/7/79/Chad.png/revision/latest?cb=20201214194847" width="200">

Run (llama.cpp distributed over MPI)[https://github.com/chadbrewbaker/llama.cpp/tree/mpi]

## Centeral Iowa Linux Users Group <br> 19 April 2023 <br>

## News for April 2023

* CFP open for 2023 Linux Plumbers Conference (November 13-15, Richmond VA, USA) 

* [Kernel Samepage Merging patch set](https://lwn.net/ml/linux-mm/20230406165339.1017597-1-shr@devkernel.io/)

* [Python 3.12 support for perf tool](https://docs.python.org/3.12/howto/perf_profiling.html).

* [Chrome ships WebGPU](https://developer.chrome.com/blog/webgpu-release/)

* [StableLM](https://github.com/stability-AI/stableLM/) released today. 

## Presentation:  Self-hosting large language models
* What is a large language model(LLM)?

* What can I do with a LLM?

* Run your own LLM - [llama.cpp](https://github.com/ggerganov/llama.cpp) and [web-llm](https://github.com/mlc-ai/web-llm)


## What is a large languge model (LLM)?

* A LLM is a data structure. Given k tokens, it outputs the probability of the next token.

* [BabyGPT](https://t.co/8jdceMLpqy) - a three bit LLM

* Tokenize -  Train - Infer trained model

* [OpenAI TickToken](https://github.com/openai/tiktoken) - high performance tokenizer.

* LLM Training can cost millions - OpenAI burned spare GPU at Azure WDM after Bitcoin crash as tax writeoff.

* Once you have a LLM - [fine-tuning can cost as low as $3](https://www.youtube.com/watch?v=yTROqe8T_eA)

* [vast.ai](https://vast.ai) - [lambdalabs](https://lambdalabs.com/service/gpu-cloud#pricing) - [Google Colab Notebooks](https://colab.research.google.com)

* [PicoGPT](https://github.com/jaymody/picoGPT/blob/main/gpt2_pico.py)

* [NanoGPT](https://github.com/karpathy/nanoGPT) - [video tutorial](https://www.youtube.com/watch?v=kCc8FmEb1nY)


## What can I do with an LLM?

* ChatGPT4 Demo

* [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - use OpenAI whisper to transcribe audio to text.

* [AutoGPT](https://github.com/Significant-Gravitas/Auto-GPT)  - [BabyAGI](https://github.com/yoheinakajima/babyagi) - use GPT and scripts to drive other GPTs and scripts.

* [Reddit GPT](https://www.reddit.com/r/ChatGPT/comments/12o29gl/gpt4_week_4_the_rise_of_agents_and_the_beginning/) has good weekly briefings.

## Run your own LLM - [llama.cpp](https://github.com/ggerganov/llama.cpp) and [web-llm](https://github.com/mlc-ai/web-llm)

* [llama.cpp](https://github.com/ggerganov/llama.cpp) - a fork of whisper.cpp - most widely used C++ code to host your own LLM.

* [Huggingface](https://huggingface.co/models) - stores open models as Git LFS.

* [web-llm](https://github.com/mlc-ai/web-llm) - uses WebGPU to run in the LLM in your browser.




