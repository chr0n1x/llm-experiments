# LLM Experiments

Local inference experiments running Qwen 3.6 models on a single GPU, comparing two serving backends: llama.cpp and vLLM.

## Backends

### llama.cpp (`llama.cpp/`)

GGUF-based server using the llama.cpp build with BLAS (BLIS) acceleration. Runs the MoE model `Qwen3.6-35B-A3B` in Q4 quantization.

**Key config:**
- Model: `unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_M` (Hugging Face)
- Context: 150k tokens, all layers on GPU
- KV cache: `q8_0`, mlock enabled
- Batch size: 8192, unified CUDA memory

### vLLM (`vllm/`)

vLLM server using the compressed model `Qwen3.6-27B` with INT4 weights via AutoRound.

**Key config:**
- Model: `Lorbus/Qwen3.6-27B-int4-AutoRound` (Hugging Face)
- Speculative decoding: MTP with 3 tokens
- Context: 256k tokens, 93% GPU memory utilization
- KV cache: `fp8_e4m3`, flashinfer attention backend
- Features: prefix caching, chunked prefill, auto tool call detection

## Setup

### llama.cpp

```bash
git submodule update --init --recursive
cd llama.cpp
# Build with BLAS acceleration (see qwen3.6-27b.bash comments)
cmake -B build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="86" \
  -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME
cmake --build build --config Release -j
```

Run: `./qwen3.6-27b.bash`

### vLLM

```bash
cd vllm
source .envrc   # sets CUDA_VERSION, HF_TOKEN, etc.
# .venv/ should already exist from initial setup
```

Run: `./qwen3.6.bash`

## Service files

Both directories include systemd unit files (`*.service`) to run the servers as persistent background processes. Copy each service file into `/etc/systemd/system/`, then reload and enable:

```bash
sudo cp llama.cpp/llama-cpp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now llama-cpp.service
```

Verify with `systemctl is-enabled llama-cpp.service` — it should report `enabled`.

## Models

The llama.cpp launcher includes several commented-out model variants for quick switching between quantizations and uncensored forks. The vLLM config is tuned for a single INT4-quantized variant.