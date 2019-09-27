镜像构建
将Dockerfile和files文件夹放在同一目录下并执行构建命令
docker build -t emqx:3.2.0 .


启动emqx容器
docker run -d \
    --name emqx31 \
    --network host \
    -e "EMQX_NAME=node1" \
    -e "EMQX_HOST=172.31.59.231" \
    emqx/emqx:v3.2.0


控制台访问
    ip   :18083 
    用户名:admin 
    密码  :public    


EMQ X 环境变量
    EMQX_NODE_NAME	Erlang 节点名称，例如: emqx@127.0.0.1
    CLUSTER_NAME  集群名称 例如:emqcl
    CLUSTER_DISCOVERY 集群发现方式 例如：etcd
    CLUSTER_ETCD_SERVER etcd服务器地址 例如：http://127.0.0.1:2379
    CLUSTER_ETCD_PREFIX 例如：emqcl
    CLUSTER_ETCD_NODE_TTL 例如：1m



#创建集群
#发现策略：etcd

启动etcd服务器
docker run \
  -d \
  --network host \
  --name etcd \
  gcr.io/etcd-development/etcd:latest \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data \
  --name etcd1 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://172.31.59.231:2379 \
  --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster=etcd1=http://172.31.59.231:2380 \
  --initial-advertise-peer-urls=http://172.31.59.231:2380



  查看节点信息
  etcdctl --endpoints=http://127.0.0.1:2379 member list
  查看集群健康
  etcdctl --endpoints=http://47.52.230.165:2379 cluster-health


启动emqx服务器
启动emqx容器
docker run -d \
    --name emqx2 \
    --network test \
    -e "CLUSTER_DISCOVERY=etcd" \
    -e "CLUSTER_ETCD_SERVER=http://172.31.59.231:2379" \
    -e "CLUSTER_ETCD_PREFIX=emqxcl" \
    -e "CLUSTER_ETCD_NODE_TTL=1m" \
    emqx:3.2.0

注：
cluster.discovery = etcd
etcd 服务器列表，以 , 进行分隔
    
cluster.etcd.server = http://127.0.0.1:2379
用于 etcd 中节点路径的前缀，集群中的每个节点都会在etcd下创建v2/keys/<prefix>/<cluster.name>/<node.name>目录

cluster.etcd.prefix = emqxcl

etcd 中节点的 TTL:
cluster.etcd.node_ttl = 1m

客户端私有PEM编码密钥
cluster.etcd.ssl.keyfile = etc/certs/client-key.pem

客户端证书文件
cluster.etcd.ssl.certfile = etc/certs/client.pem
    
PEM编码的CA证书文件
cluster.etcd.ssl.cacertfile = etc/certs/ca.pem