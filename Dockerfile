# ===== 基础镜像 =====
FROM pytorch/pytorch:2.9.1-cuda13.0-cudnn9-devel

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# ===== 系统依赖 =====
RUN apt-get update && apt-get install -y \
    git wget curl ffmpeg \
    libgl1 libglib2.0-0 ca-certificates \
    build-essential cmake \
    libglvnd0 libglvnd-dev libegl1-mesa-dev \
    libvulkan1 libvulkan-dev \
    && rm -rf /var/lib/apt/lists/*

# ===== Vulkan / EGL =====
RUN mkdir -p /usr/share/glvnd/egl_vendor.d && \
    echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libEGL_nvidia.so.0"}}' \
    > /usr/share/glvnd/egl_vendor.d/10_nvidia.json && \
    mkdir -p /usr/share/vulkan/icd.d && \
    echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libGLX_nvidia.so.0","api_version":"1.3"}}' \
    > /usr/share/vulkan/icd.d/nvidia_icd.json

# ===== 工作目录 =====
WORKDIR /comfy

# ===== Python venv =====
RUN python3 -m venv comfy-env && \
    ./comfy-env/bin/python -m pip install --upgrade pip setuptools wheel

# ===== 安装 ComfyUI =====
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /comfy/ComfyUI
RUN ../comfy-env/bin/python -m pip install --no-cache-dir -r requirements.txt

# ===== 安装 ComfyUI-Manager =====
WORKDIR /comfy/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager

# ===== 使用 cm-cli 安装缺失节点（关键）=====
COPY Wan2.2-Remix-I2V-Comfy-Qwen3.json /tmp/workflow.json
WORKDIR /comfy/ComfyUI
RUN ../comfy-env/bin/python cm-cli.py install-missing --workflow /tmp/workflow.json



# ===== 复制 entrypoint 并激活虚拟环境 ===== 
WORKDIR /comfy 
COPY entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh 

EXPOSE 8188 

ENTRYPOINT ["/entrypoint.sh"]
