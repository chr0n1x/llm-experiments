#!/bin/bash

source .envrc
source .venv/bin/activate

vllm serve "Lorbus/Qwen3.6-27B-int4-AutoRound" \
 --speculative-config '{"method":"mtp","num_speculative_tokens":3}' \
 --max-model-len "262144" \
 --gpu-memory-utilization "0.93" \
 --attention-backend flashinfer \
 --performance-mode interactivity \
 --language-model-only \
 --kv-cache-dtype "fp8_e4m3" \
 --max-num-seqs "2" \
 --skip-mm-profiling \
 --quantization auto_round \
 --reasoning-parser qwen3 \
 --enable-auto-tool-choice \
 --enable-prefix-caching \
 --enable-chunked-prefill \
 --tool-call-parser qwen3_coder \
 --host "::" \
 --port "8000"  \
