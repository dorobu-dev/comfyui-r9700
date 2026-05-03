#!/bin/bash
set -e

COMFYUI_DIR="/workspace/ComfyUI"
NODES_DIR="$COMFYUI_DIR/custom_nodes"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   comfyui-r9700 — dorobu.dev             ║"
echo "║   RDNA 4 / gfx1151 optimized             ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── ComfyUI: clone or update ────────────────────────────────────────────────
if [ -d "$COMFYUI_DIR/.git" ]; then
  echo "► Updating ComfyUI..."
  cd "$COMFYUI_DIR" && git pull --ff-only || echo "  (already up to date)"
else
  echo "► Cloning ComfyUI..."
  git clone https://github.com/comfyanonymous/ComfyUI.git /tmp/ComfyUI
  cp -r /tmp/ComfyUI/. "$COMFYUI_DIR/"
  rm -rf /tmp/ComfyUI
fi

# ── Install / update ComfyUI requirements ───────────────────────────────────
echo "► Installing ComfyUI requirements..."
cd "$COMFYUI_DIR"
pip install -r requirements.txt --quiet

# ── Custom Node Manager (ComfyUI-Manager) ───────────────────────────────────
MANAGER_DIR="$NODES_DIR/ComfyUI-Manager"
if [ -d "$MANAGER_DIR/.git" ]; then
  echo "► Updating ComfyUI-Manager..."
  cd "$MANAGER_DIR" && git pull --ff-only || true
else
  echo "► Installing ComfyUI-Manager..."
  git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
fi

if [ -f "$MANAGER_DIR/requirements.txt" ]; then
  pip install -r "$MANAGER_DIR/requirements.txt" --quiet
fi

# ── Extra custom nodes (add more here as needed) ────────────────────────────
install_node() {
  local name="$1"
  local repo="$2"
  local dir="$NODES_DIR/$name"

  if [ -d "$dir/.git" ]; then
    echo "► Updating $name..."
    cd "$dir" && git pull --ff-only || true
  else
    echo "► Installing $name..."
    git clone "$repo" "$dir"
  fi

  if [ -f "$dir/requirements.txt" ]; then
    pip install -r "$dir/requirements.txt" --quiet
  fi
}

# Uncomment to add nodes:
# install_node "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
# install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
# install_node "ComfyUI_IPAdapter_plus" "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git"

# ── MIOpen cache dir ─────────────────────────────────────────────────────────
mkdir -p /workspace/.miopen

# ── Launch ───────────────────────────────────────────────────────────────────

# Print ready message once ComfyUI responds
(
  while ! curl -s http://0.0.0.0:8188 > /dev/null 2>&1; do
    sleep 2
  done
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║   ✅ ComfyUI is ready!                   ║"
  echo "║                                          ║"
  echo "║   Open in browser:                       ║"
  echo "║   http://127.0.0.1:8188                  ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""
) &

cd "$COMFYUI_DIR"
exec python main.py --listen 0.0.0.0 ${CLI_ARGS}
