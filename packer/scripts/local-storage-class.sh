### manifest for installing rancher's local-path-provisioner

# helm template: https://github.com/rancher/local-path-provisioner/tree/master/deploy/chart/local-path-provisioner
# the template was rendered as:
# helm template local-path-storage ./local-path-provisioner/deploy/chart/local-path-provisioner/ --create-namespace -n local-path-storage --set nameOverride=local-path-provisioner --set fullnameOverride=local-path-provisioner --set storageClass.defaultClass=true --set serviceAccount.name=local-path-provisioner-service-account --set configmap.name=local-path-provisioner-config

mkdir /root/local-storage-class && cd /root/local-storage-class/
cat <<EOF > /root/local-storage-class/local-storage-class.yaml
---
# Source: local-path-provisioner/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: local-path-provisioner-service-account
  labels:
    app.kubernetes.io/name: local-path-provisioner
    helm.sh/chart: local-path-provisioner-0.0.22-dev
    app.kubernetes.io/instance: local-path-storage
    app.kubernetes.io/version: "v0.0.22-dev"
    app.kubernetes.io/managed-by: Helm
---
# Source: local-path-provisioner/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-path-provisioner-config
  labels:
    app.kubernetes.io/name: local-path-provisioner
    helm.sh/chart: local-path-provisioner-0.0.22-dev
    app.kubernetes.io/instance: local-path-storage
    app.kubernetes.io/version: "v0.0.22-dev"
    app.kubernetes.io/managed-by: Helm
data:
  config.json: |-
    {
      "nodePathMap": 
        [
          {
            "node": "DEFAULT_PATH_FOR_NON_LISTED_NODES",
            "paths": [
              "/opt/local-path-provisioner"
            ]
          }
        ]
    }
  setup: |-
    
    #!/bin/sh
    set -eu
    mkdir -m 0777 -p "\$VOL_DIR"
  teardown: |-
    
    #!/bin/sh
    set -eu
    rm -rf "\$VOL_DIR"
  helperPod.yaml: |-
    
    apiVersion: v1
    kind: Pod
    metadata:
      name: helper-pod
    spec:
      containers:
      - name: helper-pod
        image: busybox
        imagePullPolicy: IfNotPresent
---
# Source: local-path-provisioner/templates/storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
  labels:
    app.kubernetes.io/name: local-path-provisioner
    helm.sh/chart: local-path-provisioner-0.0.22-dev
    app.kubernetes.io/instance: local-path-storage
    app.kubernetes.io/version: "v0.0.22-dev"
    app.kubernetes.io/managed-by: Helm
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: cluster.local/local-path-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
allowVolumeExpansion: true
---
# Source: local-path-provisioner/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: local-path-provisioner
  labels:
    app.kubernetes.io/name: local-path-provisioner
    helm.sh/chart: local-path-provisioner-0.0.22-dev
    app.kubernetes.io/instance: local-path-storage
    app.kubernetes.io/version: "v0.0.22-dev"
    app.kubernetes.io/managed-by: Helm
rules:
- apiGroups: [""]
  resources: ["nodes", "persistentvolumeclaims", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["endpoints", "persistentvolumes", "pods"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "watch"]
---
# Source: local-path-provisioner/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: local-path-provisioner
  labels:
    app.kubernetes.io/name: local-path-provisioner
    helm.sh/chart: local-path-provisioner-0.0.22-dev
    app.kubernetes.io/instance: local-path-storage
    app.kubernetes.io/version: "v0.0.22-dev"
    app.kubernetes.io/managed-by: Helm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: local-path-provisioner
subjects:
  - kind: ServiceAccount
    name: local-path-provisioner-service-account
    namespace: local-path-storage
---
# Source: local-path-provisioner/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: local-path-provisioner
  labels:
    app.kubernetes.io/name: local-path-provisioner
    helm.sh/chart: local-path-provisioner-0.0.22-dev
    app.kubernetes.io/instance: local-path-storage
    app.kubernetes.io/version: "v0.0.22-dev"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: local-path-provisioner
      app.kubernetes.io/instance: local-path-storage
  template:
    metadata:
      labels:
        app.kubernetes.io/name: local-path-provisioner
        app.kubernetes.io/instance: local-path-storage
    spec:
      serviceAccountName: local-path-provisioner-service-account
      containers:
        - name: local-path-provisioner
          image: "rancher/local-path-provisioner:master-head"
          imagePullPolicy: IfNotPresent
          command:
            - local-path-provisioner
            - --debug
            - start
            - --config
            - /etc/config/config.json
            - --service-account-name
            - local-path-provisioner-service-account
            - --provisioner-name
            - cluster.local/local-path-provisioner
            - --helper-image
            - "busybox:latest"
            - --configmap-name
            - local-path-provisioner-config
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config/
          env:
            - name: POD_NAMESPACE
              value: local-path-storage
          resources:
            {}
      volumes:
        - name: config-volume
          configMap:
            name: local-path-provisioner-config
EOF
