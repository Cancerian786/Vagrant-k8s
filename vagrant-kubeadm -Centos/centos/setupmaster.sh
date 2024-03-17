#!/bin/bash

echo "[TASK 1] Pull required containers"
hostnamectl set-hostname k8s
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Disable Swapoff"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 3] Remove Containerd"
rm /etc/containerd/config.toml
systemctl restart containerd

echo "[TASK 4] Initialize Kubernetes Cluster"
kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-advertise-address=192.168.56.101>> /root/kubeinit.log >/dev/null

echo "[TASK 5] Deploy Weave network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml >/dev/null 2>&1

echo "[TASK 6] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 7] Setup public key for workers to access master"
cat >>/home/vagrant/.ssh/authorized_keys<<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4+877V+fuVSgNWZ6+13uawtKfdDKwUzX+24Gm69gplkm8yJ1jIxCfUFYRRVs/oc/wpyV+p2EgEyVyGRZXThumV45a4rgKhfK0pozTnaa2sOS4TZf4YozUiO6fzHQrZQ2VxMtIiGuNIR0BxPCK53RMfWaAqQnlhF7OVimom2phbfqZDBl8NtR3M+d0tvf1Ih+1Rby7o/P8Mr2jAy1CmhwVaXm+iPStaAGL+dGmspKZBPAid44rtA5dyfdCPZp7VICYbVj/1GfVkbK+ZAbigbg7BWDMDsyy2H66Dt5NUNVxFXeJXKjl2xbNN2QtkYo4FPRuFyQc0Uc9ZVBmyUu/sXgBIqIXGRl3f4sFb9BO5pBgJVTwIn4n+vaZADiXrCiaBWyM9fm2obZwyGwIygrJ+n6OmBW12iYTJI1fBQ92dXuhf6IPVMW458zyZS+sFSYBxj9k2PdcY13RIshiDGQUo9VweJnEgdm7yroEbvMgnU+4khuph+ALTaLGVBk6bgZsxDk= ansar@Wahid
EOF

echo "[TASK 8] Setup kubectl"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config