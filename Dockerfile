FROM nvcr.io/nvidia/pytorch:24.12-py3

# 基本的なシステムツールとVSCode用ツールのインストール
RUN apt update -y && apt install -y \
    build-essential \
    curl \
    openssh-server \
    openssh-client \
    pdsh \
    tmux \
    git \
    vim \
    htop \
    iputils-ping \
    net-tools \
    wget \
    sudo \
    less \
    python3-dbg

RUN chown root:root /usr/lib
RUN pip install --upgrade pip wheel

# ML/AI関連パッケージ
RUN pip install \
        accelerate \
        deepspeed \
        openai \
        mistral_common \
        msgspec \
        peft \
        pyarrow \
        sentencepiece \
        tiktoken \
        transformers \
        trl

RUN pip install stanford-stk --no-deps

# 開発用パッケージを追加
RUN pip install \
        aioprometheus \
        fastapi \
        fschat[model_worker,webui] \
        gguf \
        lm-format-enforcer \
        llmcompressor \
        outlines \
        partial_json_parser \
        prometheus-fastapi-instrumentator \
        ray==2.34.0 \
        typer \
        uvicorn[standard] \
        ipython \
        black \
        flake8 \
        mypy \
        pylint \
        pytest \
        debugpy

RUN pip uninstall -y pynvml
RUN pip install nvidia-ml-py

# GPU関連の最適化パッケージをインストール
RUN mkdir /packages/

ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/flash_attn-2.7.2.post1-cp312-cp312-linux_aarch64.whl /packages/flash_attn-2.7.2.post1-cp312-cp312-linux_aarch64.whl
ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/flash_attn-2.7.2.post1-cp312-cp312-linux_x86_64.whl /packages/flash_attn-2.7.2.post1-cp312-cp312-linux_x86_64.whl
RUN pip install --no-deps --no-index --upgrade --find-links /packages flash-attn

ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/xformers-0.0.30%2B46a02df6.d20250103-cp312-cp312-linux_aarch64.whl /packages/xformers-0.0.30+46a02df6.d20250103-cp312-cp312-linux_aarch64.whl
ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/xformers-0.0.30%2B46a02df6.d20250103-cp312-cp312-linux_x86_64.whl /packages/xformers-0.0.30+46a02df6.d20250103-cp312-cp312-linux_x86_64.whl
RUN pip install --no-deps --no-index --find-links /packages xformers

ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/megablocks-0.7.0-cp312-cp312-linux_aarch64.whl /packages/megablocks-0.7.0-cp312-cp312-linux_aarch64.whl
ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/megablocks-0.7.0-cp312-cp312-linux_x86_64.whl /packages/megablocks-0.7.0-cp312-cp312-linux_x86_64.whl
RUN pip install --no-deps --no-index --find-links /packages megablocks

ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/bitsandbytes-0.45.1.dev0-cp312-cp312-linux_aarch64.whl /packages/bitsandbytes-0.45.1.dev0-cp312-cp312-linux_aarch64.whl
ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/bitsandbytes-0.45.1.dev0-cp312-cp312-linux_x86_64.whl /packages/bitsandbytes-0.45.1.dev0-cp312-cp312-linux_x86_64.whl
RUN pip install --no-deps --no-index --find-links /packages bitsandbytes

ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/vllm-0.6.6.post1%2Bcu126-cp312-cp312-linux_aarch64.whl /packages/vllm-0.6.6.post1+cu126-cp312-cp312-linux_aarch64.whl
ADD https://static.abacus.ai/pypi/abacusai/gh200-llm/pytorch-2412-cuda126/vllm-0.6.6.post1%2Bcu126-cp312-cp312-linux_x86_64.whl /packages/vllm-0.6.6.post1+cu126-cp312-cp312-linux_x86_64.whl
RUN pip install --no-deps --no-index --find-links /packages vllm

RUN rm -r /packages

# 作業ディレクトリの設定
WORKDIR /workspace

# デフォルトのシェルをbashに設定
SHELL ["/bin/bash", "-c"]

# 開発用の環境変数を設定
ENV PYTHONPATH="${PYTHONPATH}:/workspace"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
