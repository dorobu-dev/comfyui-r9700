# comfyui-r9700

> ComfyUI Docker image built and tested exclusively on the  
> **AMD Radeon RX 9700 / R9700 AI Pro** (RDNA 4, gfx1151)

[![Docker Pulls](https://img.shields.io/docker/pulls/dorobu/comfyui-r9700)](https://hub.docker.com/r/dorobu/comfyui-r9700)
[![Build](https://github.com/dorobu-dev/comfyui-r9700/actions/workflows/build.yml/badge.svg)](https://github.com/dorobu-dev/comfyui-r9700/actions)

---

## Why this exists

Most ComfyUI ROCm images are either stale, untested on real hardware, or try to support every AMD GPU and end up supporting none well.

This image is different:

- ✅ Built and tested on a real R9700 AI Pro
- ✅ Always runs the **latest ComfyUI** (auto-updates on every container start)
- ✅ **ROCm 7.1** — optimized for RDNA 4 (gfx1151)
- ✅ **ComfyUI-Manager** included out of the box
- ✅ MIOpen kernel cache persisted across restarts (faster after first run)
- ⚠️ Not tested on other GPUs — may work on other RDNA 4 cards, no guarantees

---

## Quick Start

```bash
# Pull and run
docker run -d \
  --name comfyui-r9700 \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add=video \
  --group-add=render \
  --ipc=host \
  -p 8188:8188 \
  -v $(pwd)/models:/workspace/ComfyUI/models \
  -v $(pwd)/output:/workspace/ComfyUI/output \
  dorobu/comfyui-r9700:latest
```

Open **http://localhost:8188**

---

## Docker Compose (recommended)

```bash
# Download compose file
curl -O https://raw.githubusercontent.com/dorobu-dev/comfyui-r9700/main/docker-compose.yml

# Start
docker compose up -d

# Follow logs
docker compose logs -f
```

---

## Host Prerequisites

Your Linux host needs ROCm drivers and your user in the right groups:

```bash
# Add user to GPU groups
sudo usermod -a -G render,video $USER

# Verify GPU is accessible
ls /dev/kfd /dev/dri
```

For full ROCm driver install see the [AMD ROCm docs](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/).

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `CLI_ARGS` | _(empty)_ | Extra args passed to `main.py` e.g. `--lowvram` |

---

## Adding Custom Nodes

Uncomment lines in `entrypoint.sh` to pre-install nodes, or use **ComfyUI-Manager** (included) to install them from the UI.

Nodes installed via ComfyUI-Manager are persisted if you mount the `custom_nodes` volume.

---

## Specs

| Component | Version |
|---|---|
| Base image | `rocm/pytorch:rocm7.1_ubuntu24.04_py3.12_pytorch_release_2.6.0` |
| ROCm | 7.1 |
| Python | 3.12 |
| Target GPU | gfx1151 (RDNA 4) |
| ComfyUI | latest (pulled on start) |

---

## First Run Note

The first image generation will be slow — MIOpen compiles optimized kernels for your GPU on first use. This is normal. Subsequent runs are significantly faster, especially if you mount the `.miopen` cache volume.

---

## Links

- [dorobu.dev](https://dorobu.dev)
- [Docker Hub](https://hub.docker.com/r/dorobu/comfyui-r9700)
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [AMD ROCm](https://rocm.docs.amd.com)

---

MIT License — go build stuff.
