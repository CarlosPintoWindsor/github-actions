#!/bin/bash

set -xe

echo "Wrap Edge Chromium binary"

WRAPPER_PATH=$(readlink -f /usr/bin/microsoft-edge)
BASE_PATH="$WRAPPER_PATH-base"
mv "$WRAPPER_PATH" "$BASE_PATH"

cat > "$WRAPPER_PATH" <<_EOF
#!/bin/bash
# Note: exec -a below is a bashism.
exec -a "\$0" "$BASE_PATH" --no-sandbox "\$@"
_EOF
chmod +x "$WRAPPER_PATH"