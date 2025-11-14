<div align="center">
  <img src="logo.png" alt="Seawise Logo" width="200"/>

  # Rancher Installation - Simplified Guide

  Quick and easy guide to install Seawise Dashboard on Rancher clusters

  [🌐 seawise.cloud](https://seawise.cloud) | [📦 GitHub](https://github.com/shwcloudapp/seawise-backup)

</div>

---

## ✅ Before You Start

You need:
- ✅ Rancher cluster running (RKE/RKE2/K3s)
- ✅ Velero installed (usually in `velero` namespace)
- ✅ kubectl or oc CLI access configured

---

## 🎯 Installation in 3 Steps

### Step 1: Discover Cluster IP

```bash
kubectl get nodes -o wide
```

Note the **INTERNAL IP** of any node (example: `192.168.100.97`)

---

### Step 2: Create Configuration File

**Copy and paste this command** (it will create the file automatically):

```bash
cat > rancher-values.yaml <<'YAML'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.5.0"
  pullPolicy: IfNotPresent

app:
  veleroNamespace: "velero"
  timezone: "America/Sao_Paulo"

ingress:
  enabled: true
  className: ""
  annotations:
    kubernetes.io/ingress.allow-http: "false"
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
  hosts:
    - host: seawise-backup.192.168.100.97.sslip.io
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - seawise-backup.192.168.100.97.sslip.io

persistence:
  enabled: true
  storageClassName: "local-path"
  size: 1Gi

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
YAML
```

**Now edit the IP:**

```bash
# Replace 192.168.100.97 with your cluster IP
sed -i 's/192.168.100.97/YOUR_IP_HERE/g' rancher-values.yaml

# Or edit manually:
nano rancher-values.yaml
# Change lines 18 and 23
```

---

### Step 3: Install

**Latest Version:** Check [releases](https://github.com/shwcloudapp/seawise-backup/releases/latest)

```bash
# Set the version
export CHART_VERSION=1.5.7

helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-values.yaml
```

**Done!** Wait 1-2 minutes and access:

```
https://seawise-backup.YOUR-IP.sslip.io
```

---

## 🔍 Verify Installation

```bash
# Check if pod is running
kubectl get pods -n seawise-app

# Check Ingress
kubectl get ingress -n seawise-app

# View logs (if needed)
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f
```

**Expected output:**

```
NAME                                 READY   STATUS    RESTARTS   AGE
seawise-dashboard-xxxxxxxxxx-xxxxx   1/1     Running   0          2m

NAME                CLASS     HOSTS                                   PORTS     AGE
seawise-dashboard   traefik   seawise-backup.192.168.100.97.sslip.io   80, 443   2m
```

---

## 🌐 If You Use NGINX Instead of Traefik

If your Rancher uses NGINX Ingress Controller, use this file:

```bash
cat > rancher-nginx-values.yaml <<'YAML'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.5.0"
  pullPolicy: IfNotPresent

app:
  veleroNamespace: "velero"
  timezone: "America/Sao_Paulo"

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"  # Se tiver cert-manager
  hosts:
    - host: seawise-backup.192.168.100.97.sslip.io
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - seawise-backup.192.168.100.97.sslip.io
      # secretName: seawise-tls  # Descomente se usar cert-manager

persistence:
  enabled: true
  storageClassName: "local-path"
  size: 1Gi

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
YAML

# Edit the IP
sed -i 's/192.168.100.97/YOUR_IP_HERE/g' rancher-nginx-values.yaml

# Install
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-nginx-values.yaml
```

---

## ⚙️ Common Configurations

### Change Timezone

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.timezone="America/New_York"
```

### Use Custom Domain

If you have a domain (example: `backup.mycompany.com`):

```bash
# Edit the file
nano rancher-values.yaml

# Change:
# hosts:
#   - host: backup.mycompany.com

# Update
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  -f rancher-values.yaml
```

### Change Velero Namespace

If Velero is in a different namespace:

```bash
# Find it
kubectl get deployment --all-namespaces | grep velero

# Update
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="cattle-velero"
```

---

## 🐛 Common Issues

### 1. Pod Not Starting (CrashLoopBackOff)

```bash
# View logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Check PVC
kubectl get pvc -n seawise-app
```

**Solution:** Usually a storage issue. Check if StorageClass exists:

```bash
kubectl get storageclass
```

If `local-path` doesn't exist, use another one (example: `default`, `nfs-client`):

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set persistence.storageClassName="default"
```

---

### 2. Ingress Not Appearing / URL Not Working

```bash
# Check which Ingress Controller is installed
kubectl get pods -n kube-system | grep -E "traefik|nginx"

# Check the created Ingress
kubectl describe ingress -n seawise-app seawise-dashboard
```

**Solutions:**

- **Traefik not installed?** Use the NGINX configuration above
- **Wrong IP?** Check the IP with `kubectl get nodes -o wide`
- **Firewall?** Test with port-forward: `kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80`

---

### 3. "Velero not found" in Dashboard

```bash
# Find where Velero is installed
kubectl get deployment --all-namespaces | grep velero

# If it's in a different namespace, update:
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="CORRECT-NAMESPACE"
```

---

### 4. Invalid SSL Certificate

This is **normal** with sslip.io! Traefik generates a self-signed certificate.

**Solutions:**

1. **Accept the certificate** in your browser (click "Advanced" → "Continue")
2. **Use cert-manager** for real Let's Encrypt certificates
3. **Use your own domain** with configured SSL

---

## 🔄 Update to New Version

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --reuse-values
```

---

## 🗑️ Uninstall

```bash
# Remove application
helm uninstall seawise-dashboard -n seawise-app

# Remove data (CAUTION: deletes the database!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc

# Remove namespace
kubectl delete namespace seawise-app
```

---

## 🆘 Need Help?

- 📖 [Complete Documentation](README.md)
- 📖 [General Guide](USER-INSTALL-GUIDE.md)
- 🐛 [Report Issue](https://github.com/shwcloudapp/seawise-backup/issues)

---

## 📋 Complete Command Summary

For convenience, here's the complete command in a single block:

```bash
# 1. Create configuration file
cat > rancher-values.yaml <<'YAML'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.5.0"
  pullPolicy: IfNotPresent
app:
  veleroNamespace: "velero"
  timezone: "America/Sao_Paulo"
ingress:
  enabled: true
  className: ""
  annotations:
    kubernetes.io/ingress.allow-http: "false"
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
  hosts:
    - host: seawise-backup.192.168.100.97.sslip.io
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - seawise-backup.192.168.100.97.sslip.io
persistence:
  enabled: true
  storageClassName: "local-path"
  size: 1Gi
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
YAML

# 2. EDIT the IP (change 192.168.100.97 to your cluster IP)
nano rancher-values.yaml

# 3. Install
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v${CHART_VERSION}/seawise-dashboard-${CHART_VERSION}.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-values.yaml

# 4. Verify
kubectl get pods,ingress -n seawise-app

# 5. Access
echo "Access: https://seawise-backup.YOUR-IP.sslip.io"
```

**Done! 🎉**
