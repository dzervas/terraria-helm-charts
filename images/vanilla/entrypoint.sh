#!/bin/sh

# Capture the args first and then pass them to the command, directly using "$@" ignores them
# shellcheck disable=SC2116
args=$(echo "$@")
echo "Running server with command flags: $args"

# Workaround worldpath being ignored and not defaulting to /data/worlds

mkdir -p /tmp/terraria
config=$(echo "$args" | pcregrep -o2 '(^|\s)(-config\s+[^\s]+)')
# Copy the config so we can modify it
if [ -n "$config" ]; then
  args=$(echo "$args" | sed "s@$config@@g")
  config=$(echo "$config" | pcregrep -o1 '\s+([^\s]+)$')
  cp "$config" "/tmp/terraria/serverconfig.txt"
fi

config="/tmp/terraria/serverconfig.txt"
touch "$config"

# Extract world arg
world=$(echo "$args" | pcregrep -o2 '(^|\s)(-world\s+[^\s]+)')
if [ -n "$world" ]; then
  args=$(echo "$args" | sed "s@$world@@g")
  world=$(echo "$world" | pcregrep -o1 '\s+([^\s]+)$')
fi

# No world is set through args, check the config
if [ -z "$world" ] && [ -n "$config" ]; then
  echo "Check config world"
  world=$(cat "$config" | pcregrep -o1 '^(\s*world\s*=\s*[^\s]+)')
  if [ -n "$world" ]; then
    sed -i "s@$world@@g" "$config"
    world=$(echo "$world" | pcregrep -o1 '=\s*([^\s]+)')
  fi
fi

worldpath=$(echo "$args" | pcregrep -o2 '(^|\s)-worldpath\s+([^\s]+)')
# No world directory is set through args, check the config
if [ -z "$worldpath" ] && [ -n "$config" ]; then
  echo "Check config worldpath"
  worldpath=$(cat "$config" | pcregrep -o1 '^(\s*worldpath\s*=\s*[^\s]+)')
  if [ -n "$worldpath" ]; then
    sed -i "s@$worldpath@@g" "$config"
    worldpath=$(echo "$worldpath" | pcregrep -o1 '=\s*([^\s]+)')
  fi
fi

# Default world directory
if [ -z "$worldpath" ]; then
  echo "Fallback to default worldpath"
  worldpath="/data/worlds"
fi

# World directory doesn't end with / so add it
if [ -z "$(echo "$worldpath" | pcregrep '/$')" ]; then
  worldpath="$worldpath/"
fi

# World directory doesn't start with / so put it relative to the workdir
if [ -z "$(echo "$worldpath" | pcregrep '/$')" ]; then
  worldpath="/data/$worldpath"
fi

if [ -n "$world" ]; then
  # Check if the path is absolute, if not, set it relative to the world directory
  if [ -z "$(echo "$world" | pcregrep '^/')" ]; then
    args="$args -world $worldpath$world"
  else
    args="$args -world $world"
  fi
fi

echo "worldpath=$worldpath" >> "$config"
args="$args -config $config"

# Fix the 'Your mono runtime and class libraries are out of sync.' error
rm /terraria-server/System*
rm /terraria-server/Mono*
rm /terraria-server/monoconfig
rm /terraria-server/mscorlib.dll

# shellcheck disable=SC2086
mono --server --gc=sgen -O=all /terraria-server/TerrariaServer.exe $args
