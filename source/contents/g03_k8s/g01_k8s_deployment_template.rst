================================
K8s 部署模板
================================

K8s 部署模板
===========================

PersistentVolume (PV) 和 PersistentVolumeClaim (PVC) 模板
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

在 Kubernetes 中，PersistentVolume（PV）用于管理持久化存储资源，而 PersistentVolumeClaim（PVC）是用户请求存储资源的方式。PVC 会自动绑定到一个合适的 PV 上，支持在 Pod 生命周期之外持久存储数据。

示例（PV）：

.. code-block:: yaml

  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: <pv-name>
  spec:
    capacity:
      storage: 5Gi  # 预定存储大小
    accessModes:
    - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    hostPath:
      path: "/mnt/data"

示例（PVC）：

.. code-block:: yaml

  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: <pvc-name>
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 5Gi  # 请求的存储大小

ConfigMap 模板
>>>>>>>>>>>>>>>>>>>>>>>>>


ConfigMap 用于存储配置信息，应用程序可以从 ConfigMap 中读取配置信息，避免硬编码。ConfigMap 支持将配置作为环境变量、命令行参数或者文件挂载到容器内。

示例：

.. code-block:: yaml

  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: <configmap-name>
  data:
    <key1>: <value1>
    <key2>: <value2>

Secret 模板
>>>>>>>>>>>>>>>>>>>>>>>


Secret 用于存储敏感数据（如密码、API 密钥等），可以加密存储。与 ConfigMap 类似，Secret 也可以挂载为环境变量或文件。

示例：

.. code-block:: yaml

  apiVersion: v1
  kind: Secret
  metadata:
    name: <secret-name>
  type: Opaque
  data:
    username: <base64-encoded-username>
    password: <base64-encoded-password>


deployment模板
>>>>>>>>>>>>>>>>>>>>>>>>>>

Deployment 是 Kubernetes 中最常用的资源对象之一，用于部署和管理应用的副本。通过 Deployment，可以确保指定数量的 Pod 始终处于运行状态，并且支持版本控制、滚动更新、回滚等功能。

示例：

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: <app-name>
    labels:
      app: <app-name>
  spec:
    replicas: 3 # 指定副本数量
    selector:
      matchLabels:
        app: <app-name>
    template:
      metadata:
        labels:
          app: <app-name>
      spec:
        containers:
        - name: <app-name>
          image: <image-name>:<tag> # 镜像地址及标签
          ports:
          - containerPort: 80 # 暴露的容器端口
          env:
          - name: ENV_VAR_NAME # 环境变量
            value: "value"
          resources:
            requests:
              cpu: "100m"
              memory: "256M1"
            limits:
              cpu: "500m"
              memory: "512M1"

Service 模板
>>>>>>>>>>>>>>>>>>>>>>>>>>

Service 用于在 Kubernetes 集群内或集群外暴露应用的端口，方便访问。它为 Pod 提供统一的访问接口，并且支持负载均衡。


示例：

.. code-block:: yaml

  apiVersion: v1
  kind: Service
  metadata:
    name: <app-name>-service
  spec:
    selector:
      app: <app-name>
    ports:
    - protocol: TCP
      port: 80 # 服务端口
      targetPort: 80 # 容器端口
    type: ClusterIP # 可选值: ClusterIP, NodePort, LoadBalancer


Horizontal Pod Autoscaler (HPA) 模板
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


HPA 用于自动调整应用的副本数量，通常基于 CPU 或内存利用率。当应用负载增加时，HPA 会自动增加 Pod 副本数，反之亦然，确保系统始终保持高效的资源利用。

示例：

.. code-block:: yaml

  apiVersion: autoscaling/v2
  kind: HorizontalPodAutoscaler
  metadata:
    name: <app-name>-hpa
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: <app-name>
    minReplicas: 1
    maxReplicas: 10
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80 # 当 CPU 使用率超过 80% 时，自动扩展

Ingress 模板
>>>>>>>>>>>>>>>>>>>>


Ingress 是 Kubernetes 中用于管理外部访问的资源对象，它通常用于 HTTP/HTTPS 流量的路由，能够将外部请求根据不同的路径或域名转发到集群内部的 Service。

示例：

.. code-block:: yaml

  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: <app-name>-ingress
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
  spec:
    rules:
    - host: <your-domain.com>
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: <app-name>-service
              port:
                number: 80

StatefulSet 模板
>>>>>>>>>>>>>>>>>>>>>>>>>


StatefulSet 用于管理有状态应用，能够提供稳定的网络身份和持久化存储。它适用于需要顺序部署、稳定标识符（如数据库、缓存系统等）的应用。

示例：

.. code-block:: yaml

  apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    name: <statefulset-name>
  spec:
    serviceName: "<statefulset-name>-service"
    replicas: 3
    selector:
      matchLabels:
        app: <statefulset-name>
    template:
      metadata:
        labels:
          app: <statefulset-name>
      spec:
        containers:
        - name: <statefulset-name>
          image: <image-name>:<tag>
          volumeMounts:
          - name: <volume-name>
            mountPath: /data
    volumeClaimTemplates:
    - metadata:
        name: <volume-name>
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 5Gi

资源关系
==========================


核心工作负载组件
>>>>>>>>>>>>>>>>>>>>>>>

1. Deployment：无状态应用部署
   
   - 管理Pod副本集的声明式更新
   - 支持滚动更新和回滚机制
   - 适用于无状态应用（如Web服务、API服务）
   - 通过ReplicaSet确保指定数量的Pod副本运行
   - 支持健康检查和就绪检查

2. StatefulSet：有状态应用的部署

   - 使用 volumeClaimTemplates 为每个Pod动态创建PVC
   - 为每个Pod提供稳定的唯一标识符和持久化存储
   - 适用于有状态服务（如数据库、消息队列等）
   - 确保Pod有序部署、扩缩容和删除

3. DaemonSet：守护进程集
   
   - 在集群的每个节点上运行一个Pod副本
   - 新节点加入集群时自动部署Pod
   - 适用于系统级服务（如日志收集、监控代理）
   - 节点移除时自动删除对应Pod
  
4. Job/CronJob：任务调度
   
   - Job：运行一次性任务直到完成
   - CronJob：基于时间调度运行周期性任务
   - 任务完成后Pod自动终止
   - 支持并行执行和重试机制

服务发现与网络
>>>>>>>>>>>>>>>>>>>>>>>

1. Service（服务抽象）
   
   - 为Pod提供稳定的网络端点
   - 实现负载均衡和服务发现
   - 四种类型：
  
     + ClusterIP：集群内部访问
     + NodePort：节点端口暴露
     + LoadBalancer：云提供商负载均衡器
     + ExternalName：外部服务别名

   - 通过Label Selector关联后端Pod

2. Ingress（入口控制器）
   
   - 管理外部访问集群内部服务的HTTP/HTTPS路由
   - 提供基于域名和路径的路由规则
   - 支持TLS终止和SSL重定向
   - 需要Ingress Controller支持（如Nginx、Traefik）

配置管理
>>>>>>>>>>>>>>>>>>>>>>>

1. ConfigMap（配置管理）
   
   - 存储非敏感的应用配置数据
   - 支持键值对或配置文件形式
   - 可挂载为环境变量或文件卷
   - 实现配置与容器镜像分离

2. Secret（密钥管理）
   
   - 存储敏感信息（密码、令牌、密钥）
   - 数据默认使用Base64编码
   - 支持多种类型：Opaque、docker-registry、tls等
   - 可挂载为环境变量或文件卷

存储管理
>>>>>>>>>>>>>>>>>>>>>>>

.. list-table:: Volume 类型与特性场景
   :header-rows: 1
   :widths: 30 70

   * - Volume 类型
     - 特性与场景
   * - emptyDir
     - Pod 内多个容器共享临时目录，Pod 结束数据消失
   * - hostPath
     - 直接挂宿主机目录，不建议生产使用
   * - configMap / secret
     - 将配置文件或密钥以文件形式挂载
   * - nfs、cephfs 等
     - 挂载外部存储解决方案
   * - persistentVolumeClaim
     - 挂载集群级别持久卷（PVC）

1. PersistentVolume (PV)：集群存储资源
   
   - 定义了实际的存储容量和访问模式
   - 使用 hostPath 方式（仅适用于单节点测试环境）
   - 支持多种存储类型：NFS、云存储、本地存储等
   - 由集群管理员预先创建

2. PersistentVolumeClaim (PVC)：存储资源请求
   
   - 声明需要的存储容量和访问模式
   - 绑定到合适的 PV
   - 用户无需关心底层存储细节
   - 动态或静态方式与PV绑定

3. StorageClass：存储类
   
   - 定义动态创建PV的模板
   - 按需自动创建PV
   - 支持不同的存储后端和参数
   - 简化存储管理流程


自动扩缩容
>>>>>>>>>>>>>>>>>>>>>>>

1. HorizontalPodAutoscaler：HPA
   
   - 基于CPU、内存或自定义指标自动调整Pod副本数
   - 确保应用性能和高可用性
   - 支持扩缩容行为策略配置
   - 可设置最小和最大副本数

2. VerticalPodAutoscaler：VPA
   
   - 自动调整Pod的资源请求和限制
   - 优化资源利用率
   - 支持更新模式和推荐模式

组件协作关系图
==========================


.. code-block:: text

            ┌─────────────────────────────────────────────────────────────┐
            │                    外部用户访问                                │
            └──────────────────────────┬──────────────────────────────────┘
                                      │
                                      ▼
                                ┌─────────────┐
                                │   Ingress   │ ← 路由规则、TLS终止
                                └──────┬──────┘
                                      │
                                      ▼
                                ┌─────────────┐
                                │   Service   │ ← 负载均衡、服务发现
                                └──────┬──────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
            ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
            │ Deployment  │   │ StatefulSet │   │   DaemonSet │
            │  (Pod群组)   │   │  (Pod群组)   │   │  (Pod群组)   │
            └──────┬──────┘   └──────┬──────┘   └──────┬──────┘
                  │                 │                 │
                  ├─────────────────┼─────────────────┤
                  │                 │                 │
                  ▼                 ▼                 ▼
            ┌─────────────────────────────────────────────────┐
            │                    Pod容器组                      │
            ├─────────────────────────────────────────────────┤
            │  • 应用容器 (App Container)                      │
            │  • 边车容器 (Sidecar Container)                  │
            │  • 初始化容器 (Init Container)                   │
            └─────┬────────────────────┬────────────────────┬┘
                  │                    │                    │
                  │                    │                    │
                  ▼                    ▼                    ▼
            ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
            │  ConfigMap  │    │   Secret    │    │    PVC      │
            │  (配置数据)  │    │  (敏感信息)  │    │ (存储请求)   │
            └─────────────┘    └─────────────┘    └──────┬──────┘
                                                          │
                                                          ▼
                                                  ┌─────────────┐
                                                  │     PV      │
                                                  │  (存储资源)  │
                                                  └─────────────┘

典型应用架构示例

Web应用完整部署

.. code-block:: text

  用户访问 → Ingress → Service → Deployment Pods
                              ↓
                        ConfigMap/Secret
                              ↓
                       数据库访问 → Service → StatefulSet Pods → PVC → PV

数据处理流水线

.. code-block:: text

  CronJob触发 → Job Pods → 读取ConfigMap
                           ↓
                    处理数据 → 写入PersistentVolume
                           ↓
                    DaemonSet收集日志 → 发送到监控系统