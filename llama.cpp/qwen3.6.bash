#!/bin/bash

# building with:
# using BLIS https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/BLIS.md
#   cmake -B build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="86" -DGGML_CUDA_FA_ALL_QUANTS="true" -DGGML_CUDA_FORCE_MMQ="true" -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME
#   cmake --build build --config Release -j

# https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#performance-tuning
export GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
export GGML_CUDA_FA_ALL_QUANTS=true
export GGML_CUDA_FORCE_MMQ=true

# pick poison

# -hf unsloth/Qwen3.6-27B-GGUF:Q4_K_S \
# -hf unsloth/Qwen3.6-27B-GGUF:Q5_K_S \
# -hf unsloth/Qwen3.6-27B-NVFP4 \
# -hf llmfan46/Qwen3.6-27B-uncensored-heretic-v2-GGUF:Q3_K_M \
# -hf llmfan46/Qwen3.6-27B-uncensored-heretic-v2-GGUF:Q3_K_L \
# -hf llmfan46/Qwen3.6-27B-uncensored-heretic-v2-GGUF:Q5_K_S \

# -hf unsloth/Qwen3.6-35B-A3B:UD-Q4_K_M \
# -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_S \
# -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_M \
# -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q5_K_S \
# -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q5_K_M \
# -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q5_K_M \
# -hf llmfan46/Qwen3.6-35B-A3B-uncensored-heretic-GGUF:Q3_K_M \

/home/kran/Code/kran/llm-experiments/llama.cpp/llama.cpp/build/bin/llama-server \
  -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q5_K_M \
  --n-cpu-moe 10 \
  --host :: \
  --port 8000 \
  --n-gpu-layers all --ctx-size 256000 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --mlock \
  --flash-attn on \
  --threads-batch 8 --threads 8 --parallel 1 \
  --cont-batching --batch-size 8192 --ubatch-size 2048 \
  --prio 3 --poll 100 \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --presence-penalty 1.5 \
  --min-p 0.00 \
  --reasoning off
  --spec-type draft-mtp --spec-draft-n-max 3 # for MTP


  # --draft-max 16 --draft-min 1 --draft-p-min 0.6
  # --temp 0.6 \
  # --top-k 20 \
  # --top-p 0.95 \
  # --min-p 0.0 \
  # --repeat-penalty 1.0 \
  # --presence-penalty 0 \
  # --prio 3 \
  # --spec-type ngram-mod \
  # --spec-ngram-size-n 24 \
  # --draft-min 4 \
  # --draft-max 48 \
  # --no-mmproj

  # --cache-type-k q8_0 \
  # --cache-type-v q8_0 \
  # --host :: \
  # --port 8000
