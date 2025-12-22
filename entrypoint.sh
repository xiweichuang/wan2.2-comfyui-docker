#!/usr/bin/env bash
set -e

MODELS_DIR=/opt/ComfyUI/models

mkdir -p \
  /opt/ComfyUI/user/default/workflows \
  $MODELS_DIR/text_encoders \
  $MODELS_DIR/vae \
  $MODELS_DIR/diffusion_models \
  $MODELS_DIR/loras

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

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
  $MODELS_DIR/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors \
  $MODELS_DIR/vae/wan_2.1_vae.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors \
  $MODELS_DIR/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors \
  $MODELS_DIR/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors \
  $MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors

download_if_missing \
  https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors \
  $MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors

download_if_missing \
  https://raw.githubusercontent.com/xiweichuang/wan2.2-comfyui-docker/refs/heads/main/video_wan2_2_14B_i2v_subgraphed.json \
  /opt/ComfyUI/user/default/workflows/video_wan2_2_14B_i2v_subgraphed.json
  
echo "🚀 Starting ComfyUI API..."
echo "🚀 Starting ComfyUI API..." > /access.log
cd /opt/ComfyUI
exec ./comfyui-api --host 0.0.0.0 --port 8188
