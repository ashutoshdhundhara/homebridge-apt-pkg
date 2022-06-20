#!/bin/sh

HB_SERVICE_STORAGE_PATH="/var/lib/homebridge"
HB_SERVICE_NODE_EXEC_PATH="/opt/homebridge/bin/node"
HB_SERVICE_EXEC_PATH="/opt/homebridge/lib/node_modules/homebridge-config-ui-x/dist/bin/hb-service.js"

. "/opt/homebridge/source.sh"

cd $HB_SERVICE_STORAGE_PATH

# check for invalid package.json file
if [ -e $HB_SERVICE_STORAGE_PATH/package.json ]; then
  jq empty $HB_SERVICE_STORAGE_PATH/package.json 2>/dev/null
  if [ "$?" != 0 ]; then
    echo "ERROR: $HB_SERVICE_STORAGE_PATH/package.json is not a valid JSON file; deleting..."
    rm -rf $HB_SERVICE_STORAGE_PATH/package.json
    rm -rf $HB_SERVICE_STORAGE_PATH/pnpm-lock.yaml
    rm -rf $HB_SERVICE_STORAGE_PATH/node_modules
  fi
fi

# check for missing homebridge-config-ui-x
if [ ! -f "$HB_SERVICE_EXEC_PATH" ]; then
  echo "Re-installing homebridge-config-ui-x..."
  pnpm -C $HB_SERVICE_STORAGE_PATH install --save homebridge-config-ui-x@latest
fi

# check for missing homebridge
if [ ! -f "$HB_SERVICE_STORAGE_PATH/node_modules/homebridge/package.json" ]; then
  cd $HB_SERVICE_STORAGE_PATH
  echo "Re-installing homebridge..."
  pnpm -C $HB_SERVICE_STORAGE_PATH install --save homebridge@latest
fi

# remove homebridge-config-ui-x package from the plugins store
if [ -e "/var/lib/homebridge/node_modules/homebridge-config-ui-x" ]; then
  if [ "$(realpath /var/lib/homebridge/node_modules/homebridge-config-ui-x)" != "/opt/homebridge/lib/node_modules/homebridge-config-ui-x" ]; then
    pnpm -C $HB_SERVICE_STORAGE_PATH uninstall homebridge-config-ui-x
    rm -rf $HB_SERVICE_STORAGE_PATH/node_modules/homebridge-config-ui-x
  fi
fi

# check for missing homebridge-config-ui-x symlink
if [ ! -h "$HB_SERVICE_STORAGE_PATH/node_modules/homebridge-config-ui-x" ]; then
  ln -sf "/opt/homebridge/lib/node_modules/homebridge-config-ui-x" "$HB_SERVICE_STORAGE_PATH/node_modules/homebridge-config-ui-x"
fi

exec $HB_SERVICE_NODE_EXEC_PATH $HB_SERVICE_EXEC_PATH run -I -U $HB_SERVICE_STORAGE_PATH -P $HB_SERVICE_STORAGE_PATH/node_modules --strict-plugin-resolution "$@"
