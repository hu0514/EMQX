#!/bin/sh

## Local IP address setting

LOCAL_IP=$(hostname -i |grep -E -oh '((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])'|head -n 1)


_EMQX_HOME="/usr/local/emqx"

if [[ -z "$EMQX_NAME" ]]; then
    export EMQX_NAME="$(hostname)"
fi

if [[ -z "$EMQX_HOST" ]]; then
    export EMQX_HOST="$LOCAL_IP"
fi

if [[ -z "$EMQX_WAIT_TIME" ]]; then
    export EMQX_WAIT_TIME=5
fi

if [[ -z "$EMQX_NODE_NAME" ]]; then
    export EMQX_NODE_NAME="$EMQX_NAME@$EMQX_HOST"
fi


CONFIG="${_EMQX_HOME}/etc/emqx.conf"

declare -A dic
dic=([cluster.name]="$CLUSTER_NAME" [cluster.discovery]="$CLUSTER_DISCOVERY" [cluster.etcd.server]="$CLUSTER_ETCD_SERVER" [cluster.etcd.prefix]="$CLUSTER_ETCD_PREFIX" [cluster.etcd.node_ttl]="$CLUSTER_ETCD_NODE_TTL" [node.name]="$EMQX_NODE_NAME")

for key in $(echo ${!dic[*]})
do
 if [ ! -z ${dic[$key]} ];then
  sed -i "s&\(^## $key =.*$\|^$key =.*$\)&$key = ${dic[$key]}&g" $CONFIG
 fi
done

exec "$@"
