echo "Replace buggy native Zoom client with webapp"

if mateos-pkg-present zoom; then
  mateos-pkg-drop zoom
  mateos-webapp-install "Zoom" https://app.zoom.us/wc/home https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/zoom.png
fi
