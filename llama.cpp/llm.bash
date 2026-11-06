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
#   --n-cpu-moe 11 \
#
# -hf unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL \
# --cache-type-v q4_0 --cache-type-k q5_0 \
#
# ones below can safely use f16 cache
# --cache-type-v q8_0 --cache-type-k f16 \
#
# -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q6_K \
# -hf unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL \
# -hf unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q5_K_XL \
#
# unsloth/Qwen3.8-27B-GGUF -- note that default template is broken
#
# -hf unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL \
# --chat-template-file ./qwen3.8.template.jinja \
#
# -hf ukisai/Swift-Qwen3.8-27B-GGUF:Q5_K_M \
# -hf ukisai/Swift-Qwen3.8-27B-GGUF:Q4_K_M \
#
# just for qwen3.8 next flash
# -hf unsloth/Qwen3.8-Flash-Next-GGUF:UD-IQ3_XXS \
# -md /home/kran/Code/kran/llm-experiments/llama.cpp/unsloth/Qwen3.8-Flash-Next-GGUF/MTP/mtp-Qwen3.8-Flash-Next-shared-Q8_0.gguf \
# -hf ukisai/Swift-1.5-Qwen3.8-Flash-Next-GGUF:Q3_K_S \
# --load-mode none \
/home/kran/Code/kran/llm-experiments/llama.cpp/llama.cpp/build/bin/llama-server \
  -hf unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL \
  --cache-type-v q4_0 --cache-type-k q5_1 \
  --host :: \
  --port 8000 \
  --n-gpu-layers all --ctx-size 410000 \
  --flash-attn on \
  --threads-batch 8 --threads 8 --parallel 2 \
  --cont-batching --batch-size 8192 --ubatch-size 2048 \
  --prio 3 --poll 100 \
  --temp 1.0 \
  --top-p 0.95 \
  --min-p 0.00 \
  --top-k 20 \
  --presence-penalty 0.0 \
  --repeat-penalty 1 \
  --reasoning off \
  --jinja \
  --chat-template-file ./qwen3.8.template.jinja \
  --spec-type draft-mtp --spec-draft-n-max 2 # for MTP
