================
MicroK8s
================

安装
=============

.. code-block:: shell

  sudo snap install microk8s --classic --channel=1.33/stable
  sudo usermod -a -G microk8s $USER
  mkdir -p ~/.kube
  chmod 0700 ~/.kube



配置 HTTP/HTTPS 代理

.. code-block:: shell

  sudo nano /var/snap/microk8s/current/args/containerd-env

添加：

.. code-block:: text

  HTTP_PROXY="http://127.0.0.1:1080"
  HTTPS_PROXY="http://127.0.0.1:1080"
  NO_PROXY="127.0.0.1,localhost"


然后重启 MicroK8s：

.. code-block:: shell

  sudo microk8s stop
  sudo microk8s start

部署应用示例
.. code-block::bash

  # 创建一个 nginx 部署
  microk8s kubectl create deployment nginx --image=nginx

  # 暴露服务
  microk8s kubectl expose deployment nginx --port=80 --type=NodePort

  # 查看服务
  microk8s kubectl get services


访问 Dashboard

.. code-block::bash

  microk8s enable dashboard
  # 获取访问 token
  microk8s kubectl describe secret -n kube-system microk8s-dashboard-token
  microk8s kubectl -n kubernetes-dashboard get svc

  # 通过代理访问
  microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443


然后在浏览器访问 https://localhost:10443

启用registry 

.. code-block:: shell

  microk8s enable registry
  # 查看registry状态
  microk8s kubectl -n container-registry get pod
  microk8s kubectl -n container-registry get svc



常用命令

.. code-block:: shell

  microk8s status --wait-ready
  microk8s kubectl get nodes
  microk8s kubectl get pods -A

  sudo journalctl -u snap.microk8s.daemon-containerd -f
  microk8s kubectl get svc -n kube-system
  microk8s kubectl get svc -n container-registry
  curl http://10.152.183.242:32000/v2/_catalog
