<div align="center">
  <img src="logo.png" alt="Seawise Logo" width="200"/>

  # Seawise Dashboard - Installation Guide

  **Choose your platform and follow 3 simple steps!**

  [🌐 seawise.cloud](https://seawise.cloud) | [📦 GitHub](https://github.com/shwcloudapp/seawise-backup)

</div>

---

## 🎯 Quick Install

**Latest Version:** [v1.6.6](https://github.com/shwcloudapp/seawise-backup/releases/latest)

### For Rancher (Traefik)

```bash
# Set the version
export CHART_VERSION=1.6.6

cat > values.yaml <<'EOF'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.6.6"
app:
  veleroNamespace: "velero"
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.allow-http: "false"
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
  hosts:
    - host: seawise-backup.192.168.100.97.sslip.io  # CHANGE IP!
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - seawise-backup.192.168.100.97.sslip.io
persistence:
  enabled: true
  storageClassName: "local-path"
  accessMode: ReadWriteOnce
  size: 1Gi
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1000
EOF

nano values.yaml  # Edit IP

helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --create-namespace -f values.yaml
```

---

### For OpenShift (OADP)

```bash
# Set the version
export CHART_VERSION=1.6.6

cat > values.yaml <<'EOF'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.6.6"
app:
  veleroNamespace: "openshift-adp"
route:
  enabled: true
  tls:
    enabled: true
    termination: edge
ingress:
  enabled: false
persistence:
  enabled: true
  storageClassName: "nfs-storage-class"  # CHANGE if needed!
  size: 1Gi
podSecurityContext:
  runAsNonRoot: true
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
EOF

oc get storageclass  # Check available storage
nano values.yaml     # Edit storage class

helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --create-namespace -f values.yaml

oc get route -n seawise-app  # Get URL
```

---

### For Kubernetes (NGINX)

```bash
cat > values.yaml <<'EOF'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.6.6"
app:
  veleroNamespace: "velero"
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: seawise.example.com  # CHANGE!
      paths:
        - path: /
          pathType: Prefix
persistence:
  enabled: true
  accessMode: ReadWriteOnce
  size: 1Gi
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1000
EOF

nano values.yaml  # Edit hostname

helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --create-namespace -f values.yaml
```

---

## ✅ Verify Installation

```bash
# Check pod
kubectl get pods -n seawise-app

# Check URL (Rancher/Kubernetes)
kubectl get ingress -n seawise-app

# Check URL (OpenShift)
oc get route -n seawise-app
```

---

## 🔐 First Access

After installation, access the dashboard and login with the default credentials:

- **Username:** `admin`
- **Password:** `admin123`

> ⚠️ **Change the password immediately** after first login via Settings → Users.

---

## 💾 About the PVC

The dashboard stores all users, settings, and history in a SQLite database inside the PVC (`/data`).

> ⚠️ **Deleting the PVC will delete all data.** The actual Velero backups stored in S3/Azure/GCP are not affected.

---

## 🆘 Problems?

### Pod not starting?
```bash
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
kubectl get pvc -n seawise-app
```

### Velero not found?
```bash
kubectl get deployment --all-namespaces | grep velero
# Update veleroNamespace in values.yaml
```

---

## 📚 Detailed Guides

**Need more help? Check platform-specific guides:**

- 🐄 [Rancher Guide](RANCHER-INSTALL.md) - Traefik & NGINX
- 🔴 [OpenShift Guide](OPENSHIFT-INSTALL.md) - OADP & SCC

---

## 🔄 Update

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  -n seawise-app --reuse-values
```

---

## 🗑️ Uninstall

```bash
helm uninstall seawise-dashboard -n seawise-app
kubectl delete pvc -n seawise-app seawise-dashboard-pvc  # Optional
```

---

**That's it! 🎉**
