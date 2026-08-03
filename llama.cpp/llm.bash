#!/bin/bash

# building with:
# using BLIS https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/BLIS.md
#
#   cmake -B build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="86" -DGGML_CUDA_FA_ALL_QUANTS="true" -DGGML_CUDA_FORCE_MMQ="true" -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME
#   cmake --build build --config Release -j

# https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#performance-tuning
export GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
export GGML_CUDA_FA_ALL_QUANTS=true
export GGML_CUDA_FORCE_MMQ=true

# pick poison
# MoE number is completely arbitrary
#
# -hf unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL \
# --cache-type-v q4_0 --cache-type-k q5_0 \
#
# ones below can safely use f16 cache
# --cache-type-v f16 --cache-type-k f16 \
#
# -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q6_K \
# -hf unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL \
# -hf unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q5_K_XL \
/home/kran/Code/kran/llm-experiments/llama.cpp/llama.cpp/build/bin/llama-server \
  -hf unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL \
  --cache-type-v q4_0 --cache-type-k q5_0 \
  --n-cpu-moe 11 \
  --host :: \
  --port 8000 \
  --n-gpu-layers all --ctx-size 263000 \
  --mlock \
  --flash-attn on \
  --threads-batch 8 --threads 8 --parallel 1 \
  --cont-batching --batch-size 8192 --ubatch-size 2048 \
  --prio 3 --poll 100 \
  --temp 0.7 \
  --top-p 0.8 \
  --min-p 0.00 \
  --top-k 20 \
  --presence-penalty 1.6 \
  --reasoning off \
  --jinja \
  --spec-type draft-mtp --spec-draft-n-max 5 # for MTP
