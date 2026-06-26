# LLM Experiments

_ALL DOCS HERE ARE LLM GENERATED, ONLY MANUALLY TOUCHED CODE ARE IN llama.cpp (script and compilation)_

Local inference experiments running Qwen 3.6 models on a single GPU, comparing two serving backends: llama.cpp and vLLM.

## Hardware

- CPU: AMD Ryzen 5 5600 (12 threads)
- GPU: NVIDIA RTX 3090 (24 GB VRAM)

## Backends

### llama.cpp (`llama.cpp/`)

GGUF-based server using the llama.cpp build with BLAS (BLIS) acceleration. Runs the MoE model `Qwen3.6-35B-A3B` in Q5_K_M quantization, fitting entirely in 24 GB VRAM at ~23.4 GB with 256k context support.

**Key config:**
- Model: `unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q5_K_M` (Hugging Face)
- Context: 256k tokens, all layers on GPU (`--n-gpu-layers all`)
- KV cache: `q8_0`, mlock enabled
- Batch size: 8192, ubatch: 2048 (optimized for MoE memory access patterns)
- Threads: 8 (balanced for MoE expert GEMM parallelism)
- CUDA priority: `--prio 3 --poll 100` (reduces MoE kernel launch latency)

**Performance:** ~62 tok/s, no GPU OOM at full context.

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
# Build with BLAS acceleration (BLIS) and CUDA
cmake -B build \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="86" \
  -DGGML_CUDA_FA_ALL_QUANTS="true" \
  -DGGML_CUDA_FORCE_MMQ="true" \
  -DGGML_BLAS=ON \
  -DGGML_BLAS_VENDOR=FLAME
cmake --build build --config Release -j
```

Run: `./qwen3.6.bash`

### vLLM

```bash
cd vllm
cp envrc.sample .envrc   # edit to add your HF_TOKEN
source .envrc
# .venv/ should already exist from initial setup
```

Run: `./qwen3.6.bash`

## Service files

Both directories include systemd unit files (`*.service`) for running servers as persistent background processes. Copy the service file, edit the paths to match your local setup, then enable:

```bash
sudo cp llama.cpp/llama-cpp.service /etc/systemd/system/
# Edit paths in the service file before enabling
sudo systemctl daemon-reload
sudo systemctl enable --now llama-cpp.service
```

Verify with `systemctl is-enabled llama-cpp.service` — it should report `enabled`.

## Notes

- Both backends default to port 8000 — they are mutually exclusive. Change one if running both.
- The llama.cpp launcher includes several commented-out model variants for quick switching between quantizations and uncensored forks.
- The vLLM `.envrc` is gitignored; use `envrc.sample` as a template.
- If running with a display manager (SDDM + Hyprland), ~600 MB VRAM is consumed by the compositor, shaders, and Xorg/Wayland processes. For maximum VRAM for inference, run headless: `sudo systemctl disable --now sddm && sudo systemctl set-default multi-user.target`. Re-enable GUI with: `sudo systemctl enable --now sddm && sudo systemctl set-default graphical.target`.
