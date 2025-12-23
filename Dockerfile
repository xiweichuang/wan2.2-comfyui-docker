FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# ===== 系统依赖 =====
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    git wget curl ffmpeg \
    libgl1 libglib2.0-0 ca-certificates \
    build-essential cmake \
    && rm -rf /var/lib/apt/lists/*

# ===== 工作目录 =====
WORKDIR /comfy

# 创建虚拟环境
RUN python3 -m venv comfy-env

# 使用虚拟环境的 pip 安装
RUN comfy-env/bin/pip install --upgrade pip setuptools wheel
RUN comfy-env/bin/pip install comfy-cli
RUN comfy-env/bin/pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130


# ===== 使用 Comfy CLI 安装 ComfyUI =====
RUN /bin/bash -c "source comfy-env/bin/activate && \
    comfy --workspace=/comfy/comfyui install"


# ===== 复制 entrypoint.sh =====
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ===== 暴露 ComfyUI 端口 =====
EXPOSE 8188

# ===== 交给 entrypoint 启动 =====
ENTRYPOINT ["/entrypoint.sh"]
