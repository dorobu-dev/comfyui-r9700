FROM rocm/pytorch:rocm7.1_ubuntu24.04_py3.12_pytorch_release_2.6.0

LABEL maintainer="dorobu.dev"
LABEL description="ComfyUI for AMD Radeon RX 9700 / R9700 AI Pro (RDNA 4, gfx1151)"
LABEL org.opencontainers.image.source="https://github.com/dorobu-dev/comfyui-r9700"

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ── R9700 / RDNA 4 (gfx1151) specific environment ──────────────────────────
ENV HSA_OVERRIDE_GFX_VERSION=11.5.1
ENV ROCM_ARCH=gfx1151
ENV HIP_VISIBLE_DEVICES=0
ENV CUDA_VISIBLE_DEVICES=""

# RDNA 4 memory tuning — prevents OOM on large models
ENV PYTORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.8,max_split_size_mb:512

# MIOpen tuning cache — speeds up subsequent runs
ENV MIOPEN_USER_DB_PATH=/workspace/.miopen
ENV MIOPEN_CUSTOM_CACHE_DIR=/workspace/.miopen

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8188

ENTRYPOINT ["/entrypoint.sh"]
