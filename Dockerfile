FROM 13.1.0-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# ===== 系统依赖 =====
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    git \
    wget \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ===== 工作目录 =====
WORKDIR /comfy

# ===== 克隆 ComfyUI =====
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /comfy/ComfyUI

# ===== Python venv =====
RUN python3 -m venv venv

RUN . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip install -r requirements.txt

# ===== 复制 entrypoint =====
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ===== 暴露端口 =====
EXPOSE 8188

# 交给 entrypoint
ENTRYPOINT ["/entrypoint.sh"]
