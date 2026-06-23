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
# -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q5_K_XL \
# -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q6_K \
# -hf llmfan46/Qwen3.6-35B-A3B-uncensored-heretic-GGUF:Q3_K_M \

# most recents
# -hf unsloth/gemma-4-31B-it-qat-GGUF:UD-Q4_K_XL \

# best ones
# -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q6_K \
# -hf unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL \

# -hf unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL \
# -hfd Janvitos/gemma-4-12B-it-qat-assistant-MTP-Q8_0-GGUF:Q8_0 \

/home/kran/Code/kran/llm-experiments/llama.cpp/llama.cpp/build/bin/llama-server \
  -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q6_K \
  --n-cpu-moe 10 \
  --host :: \
  --port 8000 \
  --n-gpu-layers all --ctx-size 524000 \
  --cache-type-v f16 --cache-type-k f16 \
  --mlock \
  --flash-attn on \
  --threads-batch 8 --threads 4 --parallel 2 \
  --cont-batching --batch-size 8192 --ubatch-size 2048 \
  --prio 3 --poll 100 \
  --temp 0.0 \
  --top-p 0.7 \
  --top-k 40 \
  --presence-penalty 1.3 \
  --reasoning off \
  --min-p 0.05 \
  --spec-type draft-mtp --spec-draft-n-max 4 # for MTP

  # --jinja \
