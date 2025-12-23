#!/usr/bin/env bash
set -e

echo "🔧 Initializing ComfyUI container..."

# ===== 路径定义 =====
COMFY_ROOT=/comfy/ComfyUI
MODELS_DIR=/comfy/mnt/ComfyUI/models

# ===== 创建目录 =====
mkdir -p \
  /comfy/mnt/ComfyUI/user/default/workflows \
  $MODELS_DIR/text_encoders \
  $MODELS_DIR/vae \
  $MODELS_DIR/diffusion_models \
  $MODELS_DIR/loras

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
  $MODELS_DIR/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors

download_if_missing \
  https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors \
  $MODELS_DIR/vae/wan_2.1_vae.safetensors

download_if_missing \
  https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_fp8_scaled.safetensors \
  $MODELS_DIR/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors

download_if_missing \
  https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_fp8_scaled.safetensors \
  $MODELS_DIR/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors \
  $MODELS_DIR/vae/wan_2.1_vae.safetensors



# ===== 日志 =====
echo "🚀 Starting ComfyUI API..."
echo "🚀 Starting ComfyUI API..." > /access.log

# ===== 启动 ComfyUI =====
cd $COMFY_ROOT
source venv/bin/activate

exec python main.py --listen 0.0.0.0 --port 8188
