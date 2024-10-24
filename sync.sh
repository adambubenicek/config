#!/usr/bin/env bash
set -ue
cd "$(dirname "$0")" || exit

boot=regular
OPTIND=1
while getopts "b:" opt; do
  case "$opt" in
    b) boot=$OPTARG;;
    *) break;;
  esac
done
shift $((OPTIND-1))

ssh_host="${1:-localhost}"

printf -v divider '%80s' '' 
divider="\e[2m${divider// /=}\e[0m"

sync_dir="$(mktemp -d)"

cp remote.sh "$sync_dir/remote.sh"

ssh_opts=(
 -o ControlMaster=auto
 -o ControlPath=/root/.ssh/%C
 -o ControlPersist=60
)

HOSTNAME=$(ssh "${ssh_opts[@]}" "$ssh_host" uname -n)

echo -e "$divider"
echo -en "> Syncing to '\e[1;37m$HOSTNAME\e[0m' "
echo -e "during its '\e[1;37m$boot\e[0m' boot."

# shellcheck source=/dev/null
source .env
source colors.sh
source local.sh
source config.sh

if [[ $boot != "regular" ]]; then
  ssh_opts+=(
    -o StrictHostKeyChecking=off
    -o UserKnownHostsFile=/dev/null 
  )
fi

remote_sync_dir=$(ssh "${ssh_opts[@]}" "$ssh_host" mktemp -d)

scp "${ssh_opts[@]}" -q "$sync_dir"/* "$ssh_host:$remote_sync_dir" 
ssh "${ssh_opts[@]}" "$ssh_host" "$remote_sync_dir"/remote.sh || true
ssh "${ssh_opts[@]}" "$ssh_host" rm -rf "$remote_sync_dir"

rm -rf "$sync_dir"
