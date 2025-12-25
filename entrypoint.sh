#!/usr/bin/env bash
set -e

echo "🔧 Initializing ComfyUI container..."

# ===== 路径定义 =====
COMFY_ROOT=/comfy/ComfyUI
COMFY_VENV=/comfy/comfy-env
MODELS_DIR=/comfy/ComfyUI/models

# ===== 创建目录 =====
mkdir -p \
  $COMFY_ROOT/user/default/workflows \
  $MODELS_DIR/text_encoders \
  $MODELS_DIR/vae \
  $MODELS_DIR/unet

# ===== 下载函数 =====
download_if_missing () {
  local url="$1"
  local dest="$2"

  if [ ! -f "$dest" ]; then
    echo "⬇️  Downloading $(basename "$dest")"
    wget -c "$url" -O "$dest"
  else
    echo "✅ Found $(basename "$dest"), skip"
  fi
}

# ===== Wan 2.2 模型 =====
download_if_missing \
  https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v2.0.safetensors \
  $MODELS_DIR/unet/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v2.0.safetensors

download_if_missing \
  https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors \
  $MODELS_DIR/unet/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors

download_if_missing \
  https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_fp8_scaled.safetensors \
  $MODELS_DIR/text_encoders/nsfw_wan_umt5-xxl_fp8_scaled.safetensors

# download_if_missing \
#   https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_bf16.safetensors \
#   $MODELS_DIR/text_encoders/nsfw_wan_umt5-xxl_bf16.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors \
  $MODELS_DIR/vae/wan_2.1_vae.safetensors

download_if_missing \
  https://raw.githubusercontent.com/xiweichuang/wan2.2-comfyui-docker/refs/heads/main/Wan2.2-Remix-I2V-Comfy-Qwen3.json \
  $COMFY_ROOT/user/default/workflows/Wan2.2-Remix-I2V-Comfy-Qwen3.json



# ===== 激活 venv =====
source $COMFY_VENV/bin/activate

export COMFYUI_PATH=/comfy/ComfyUI

# ===== 核心依赖（锁死 numpy < 2）=====
pip install --no-cache-dir \
"numpy==1.26.4" \
torch torchvision torchaudio \
pillow huggingface_hub accelerate optimum av \
"transformers>=4.57.1" qwen-vl-utils \
opencv-python-headless==4.11.0.86 \
scikit-learn scikit-image imageio_ffmpeg pykalman \
insightface ultralytics \
onnxruntime-gpu==1.18.0 onnxruntime==1.18.0 \
bitsandbytes triton typer GitPython toml chardet



# 安装 workflow 需要的所有节点

python /comfy/ComfyUI/custom_nodes/comfyui-manager/cm-cli.py install \
  https://github.com/yolain/ComfyUI-Easy-Use \
  https://github.com/kijai/ComfyUI-KJNodes \
  https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite \
  https://github.com/IuvenisSapiens/ComfyUI_Qwen3-VL-Instruct \
  https://github.com/cubiq/ComfyUI_essentials \
  https://github.com/Conor-Collins/ComfyUI-CoCoTools_IO \
  https://github.com/shizuka-ai/ComfyUI-tbox \
  https://github.com/rgthree/rgthree-comfy


# 修复依赖
python /comfy/ComfyUI/custom_nodes/comfyui-manager/cm-cli.py restore-dependencies



# ===== 启动 ComfyUI =====
cd $COMFY_ROOT
exec python main.py --listen 0.0.0.0 --port 8188


# ===== 日志 =====
echo "🚀 Starting ComfyUI API..."
echo "🚀 Starting ComfyUI API..." > /access.log
