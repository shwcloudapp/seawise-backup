<div align="center">
  <img src="logo.png" alt="Seawise Logo" width="200"/>

  # Seawise Backup Dashboard - Helm Chart

  **Web interface for managing Velero/OADP backups on Kubernetes, Rancher, and OpenShift**

  [![Website](https://img.shields.io/badge/Website-seawise.cloud-blue)](https://seawise.cloud)
  [![GitHub](https://img.shields.io/badge/GitHub-seawise--backup-black)](https://github.com/shwcloudapp/seawise-backup)
  [![Release](https://img.shields.io/github/v/release/shwcloudapp/seawise-backup)](https://github.com/shwcloudapp/seawise-backup/releases)

</div>

---

## ✨ Features

- ✅ Complete backup & restore management
- ✅ Multi-platform: Kubernetes, Rancher, OpenShift
- ✅ Scheduled backups (cron policies)
- ✅ Volume backup with automatic pod annotation
- ✅ Multi-cloud support (AWS, Azure, GCP)
- ✅ Modern UI with English/Portuguese
- ✅ PDF reports
- ✅ Role-based authentication (admin, backup, viewer)
- ✅ Email notifications for backup success/failure
- ✅ Guided setup wizard for first-time configuration
- ✅ Backup Storage Location (BSL) management
- ✅ Data Protection Application (DPA) management — OpenShift OADP
- ✅ Automatic cluster detection (OpenShift / Rancher / Kubernetes)
- ✅ User management (create, edit, delete users)
- ✅ Version checker with in-app update notifications
- ✅ Custom logo upload

---

## 📦 Quick Install

**Latest Version:** [v1.7.0](https://github.com/shwcloudapp/seawise-backup/releases/latest) | [All Releases](https://github.com/shwcloudapp/seawise-backup/releases)

**Choose your platform:**

### Rancher
```bash
export CHART_VERSION=1.7.0
export CLUSTER_HOST=seawise.your-cluster-ip.sslip.io  # CHANGE
export STORAGE_CLASS=local-path                         # CHANGE if needed

helm upgrade --install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --create-namespace \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=${CLUSTER_HOST} \
  --set 'ingress.hosts[0].paths[0].path=/' \
  --set 'ingress.hosts[0].paths[0].pathType=Prefix' \
  --set persistence.storageClassName=${STORAGE_CLASS} \
  --set persistence.accessMode=ReadWriteOnce \
  --set podSecurityContext.runAsUser=1000 \
  --set podSecurityContext.fsGroup=1000 \
  --set securityContext.runAsUser=1000
```

### OpenShift
```bash
export CHART_VERSION=1.7.0
export STORAGE_CLASS=nfs-storage-class  # CHANGE: check with: oc get storageclass

helm upgrade --install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set persistence.storageClassName=${STORAGE_CLASS}
```

### Kubernetes
```bash
export CHART_VERSION=1.7.0
export CLUSTER_HOST=seawise.example.com  # CHANGE
export STORAGE_CLASS=""                   # Leave empty for default, or set your class

helm upgrade --install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --create-namespace \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=${CLUSTER_HOST} \
  --set 'ingress.hosts[0].paths[0].path=/' \
  --set 'ingress.hosts[0].paths[0].pathType=Prefix' \
  --set persistence.accessMode=ReadWriteOnce \
  --set podSecurityContext.runAsUser=1000 \
  --set podSecurityContext.fsGroup=1000 \
  --set securityContext.runAsUser=1000
```

---

## 📚 Installation Guides

**Simple step-by-step guides for each platform:**

- 📖 **[INSTALL.md](INSTALL.md)** - Quick install (3 commands)
- 🐄 **[RANCHER-INSTALL.md](RANCHER-INSTALL.md)** - Rancher with Traefik/NGINX
- 🔴 **[OPENSHIFT-INSTALL.md](OPENSHIFT-INSTALL.md)** - OpenShift with OADP

---

## 🔍 Verify Installation

```bash
kubectl get pods -n seawise-app
kubectl get ingress -n seawise-app  # or: oc get route -n seawise-app
```

---

## ⚙️ Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image | `shwcloud/seawise-backup` |
| `image.tag` | Image version | `v1.7.0` |
| `app.veleroNamespace` | Velero namespace | `velero` |
| `ingress.enabled` | Enable Ingress | `false` |
| `route.enabled` | Enable Route (OpenShift) | `false` |
| `persistence.enabled` | Enable PVC | `true` |
| `persistence.size` | PVC size | `1Gi` |

See [values.yaml](seawise-dashboard/values.yaml) for all options.

---

## 📋 Examples

Ready-to-use configuration files:

- [rancher-traefik-example.yaml](seawise-dashboard/values-examples/rancher-traefik-example.yaml)
- [rancher-nginx-example.yaml](seawise-dashboard/values-examples/rancher-nginx-example.yaml)
- [openshift-example.yaml](seawise-dashboard/values-examples/openshift-example.yaml)
- [kubernetes-example.yaml](seawise-dashboard/values-examples/kubernetes-example.yaml)

---

## 🔄 Update

```bash
# Set the new version
export CHART_VERSION=1.7.0

helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --reuse-values
```

---

## 🗑️ Uninstall

```bash
helm uninstall seawise-dashboard -n seawise-app
kubectl delete pvc -n seawise-app seawise-dashboard-pvc  # Optional: deletes data
```

---

## 🆘 Troubleshooting

### Pod not starting
```bash
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
kubectl describe pod -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
```

### Velero not found
```bash
kubectl get deployment --all-namespaces | grep velero
# Update: --set app.veleroNamespace=CORRECT-NAMESPACE
```

### No URL (Ingress/Route)
```bash
# Port-forward to test
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80
# Access: http://localhost:8080
```

---

## 📦 Releases

Latest: [v1.7.0](https://github.com/shwcloudapp/seawise-backup/releases/latest) | [View all releases](https://github.com/shwcloudapp/seawise-backup/releases)

**Recent Changes:**
- ✅ v1.7.0: [Current stable release]
- ✅ v1.5.5: Fixed HTTP 429 errors on liveness probe
- ✅ v1.7.0: Fixed OpenShift SCC compatibility
- ✅ v1.7.0: Documentation improvements

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](../CONTRIBUTING.md)

---

## 📄 License

Apache License 2.0 - see [LICENSE](../LICENSE)

---

## 🔗 Links

- **🌐 Official Website**: https://seawise.cloud
- **GitHub**: https://github.com/shwcloudapp/seawise-backup
- **Docker Hub**: https://hub.docker.com/r/shwcloud/seawise-backup
- **Issues**: https://github.com/shwcloudapp/seawise-backup/issues
- **Documentation**: [Installation Guides](#-installation-guides)

---

<div align="center">

**Made with ❤️ by Seawise Team**

[seawise.cloud](https://seawise.cloud) | [GitHub](https://github.com/shwcloudapp/seawise-backup)

</div>
