FROM nvidia/cuda:13.1.0-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# ===== 安装系统依赖 =====
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    git wget curl ffmpeg \
    libgl1 libglib2.0-0 ca-certificates \
    build-essential cmake \
    libglvnd0 libglvnd-dev libegl1-mesa-dev libvulkan1 libvulkan-dev \
    && rm -rf /var/lib/apt/lists/*

# ===== 安装 cuDNN =====
ENV NV_CUDNN_VERSION=9.17.1.4-1
ENV NV_CUDNN_PACKAGE_NAME=libcudnn9-cuda-13
ENV NV_CUDNN_PACKAGE=libcudnn9-cuda-13=${NV_CUDNN_VERSION}
ENV NV_CUDNN_PACKAGE_DEV=libcudnn9-dev-cuda-13=${NV_CUDNN_VERSION}
ENV NV_CUDNN_PACKAGE_DEV_HEADERS=libcudnn9-headers-cuda-13=${NV_CUDNN_VERSION}

RUN apt-get update && apt-get install -y \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} \
    ${NV_CUDNN_PACKAGE_DEV_HEADERS} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*

# ===== Vulkan/GL 配置 =====
RUN mkdir -p /usr/share/glvnd/egl_vendor.d && \
    echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libEGL_nvidia.so.0"}}' > /usr/share/glvnd/egl_vendor.d/10_nvidia.json && \
    mkdir -p /usr/share/vulkan/icd.d && \
    echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libGLX_nvidia.so.0","api_version":"1.3"}}' > /usr/share/vulkan/icd.d/nvidia_icd.json

# ===== 工作目录 =====
WORKDIR /comfy

# ===== 虚拟环境 =====
RUN python3 -m venv comfy-env
RUN comfy-env/bin/pip install --upgrade pip setuptools wheel
RUN comfy-env/bin/pip install comfy-cli
RUN comfy-env/bin/pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130

# ===== 安装 ComfyUI =====
RUN /bin/bash -c "source comfy-env/bin/activate && comfy --workspace=/comfy/comfyui install"

# ===== 复制 entrypoint 并激活虚拟环境 =====
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8188

ENTRYPOINT ["/entrypoint.sh"]
