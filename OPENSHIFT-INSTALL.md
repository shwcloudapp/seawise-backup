# 🚀 OpenShift Installation - Simplified Guide

Quick and easy guide to install Seawise Dashboard on OpenShift clusters with OADP.

---

## ✅ Before You Start

You need:
- ✅ OpenShift cluster running (4.10+)
- ✅ OADP (OpenShift API for Data Protection) installed
- ✅ Access with `oc` CLI configured

---

## 🎯 Installation in 3 Steps

### Step 1: Verify OADP Installation

```bash
# Check if OADP is installed
oc get deployment -n openshift-adp

# Should show velero deployment
```

If OADP is not installed, see: [OADP Installation Guide](https://docs.openshift.com/container-platform/latest/backup_and_restore/application_backup_and_restore/installing/installing-oadp-ocs.html)

---

### Step 2: Create Configuration File

**Copy and paste this command** (it will create the file automatically):

```bash
cat > openshift-values.yaml <<'YAML'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.5.0"
  pullPolicy: IfNotPresent

app:
  veleroNamespace: "openshift-adp"
  timezone: "America/Sao_Paulo"

persistence:
  enabled: true
  storageClassName: "nfs-storage-class"
  size: 1Gi

route:
  enabled: true
  host: ""
  tls:
    enabled: true
    termination: edge

ingress:
  enabled: false

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

podSecurityContext:
  fsGroup: 1001
  runAsNonRoot: true
  runAsUser: 1001

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1001
YAML
```

**Edit the StorageClass if needed:**

```bash
# Check available storage classes
oc get storageclass

# Edit the file to use your storage class
nano openshift-values.yaml
# Change line 11: storageClassName: "YOUR-STORAGE-CLASS"
```

---

### Step 3: Install

```bash
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f openshift-values.yaml
```

**Done!** Wait 1-2 minutes and get the URL:

```bash
oc get route -n seawise-app seawise-dashboard
```

Access the URL shown in the output! 🎉

---

## 🔍 Verify Installation

```bash
# Check if pod is running
oc get pods -n seawise-app

# Check the Route
oc get route -n seawise-app

# Check logs if needed
oc logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f
```

**Expected output:**

```
NAME                                 READY   STATUS    RESTARTS   AGE
seawise-dashboard-xxxxxxxxxx-xxxxx   1/1     Running   0          2m

NAME                HOST/PORT
seawise-dashboard   seawise-dashboard-seawise-app.apps.cluster.example.com
```

---

## ⚙️ Common Configurations

### Change Timezone

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.timezone="America/New_York"
```

### Use Custom Hostname

```bash
# Edit the file
nano openshift-values.yaml

# Change:
# route:
#   enabled: true
#   host: "backup.apps.cluster.example.com"

# Update
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  -f openshift-values.yaml
```

### Force HTTPS Redirect

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set route.tls.insecureEdgeTerminationPolicy="Redirect"
```

### Change OADP Namespace

If OADP is in a different namespace:

```bash
# Find OADP namespace
oc get deployment --all-namespaces | grep velero

# Update
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="YOUR-OADP-NAMESPACE"
```

---

## 🐛 Common Issues

### 1. Pod Not Starting (CrashLoopBackOff)

```bash
# View logs
oc logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Check PVC
oc get pvc -n seawise-app
```

**Solution:** Usually a storage issue. Check if the StorageClass exists:

```bash
oc get storageclass
```

If `nfs-storage-class` doesn't exist, use another one:

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set persistence.storageClassName="ocs-storagecluster-cephfs"
```

Common OpenShift storage classes:
- `ocs-storagecluster-cephfs` (OCS/ODF)
- `ocs-storagecluster-ceph-rbd` (OCS/ODF block)
- `gp2` or `gp3` (AWS EBS)
- `managed-nfs-storage` (NFS)

---

### 2. Route Not Appearing / URL Not Working

```bash
# Check if Route was created
oc describe route -n seawise-app seawise-dashboard

# Check service
oc get svc -n seawise-app
```

**Solutions:**

- **No Route?** Make sure `route.enabled=true` in the values file
- **URL not accessible?** Test with port-forward:
  ```bash
  oc port-forward -n seawise-app svc/seawise-dashboard 8080:80
  # Access: http://localhost:8080
  ```

---

### 3. "OADP not found" in Dashboard

```bash
# Find where OADP/Velero is installed
oc get deployment --all-namespaces | grep velero

# If it's in a different namespace, update:
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="CORRECT-NAMESPACE"
```

---

### 4. Permission Errors

```bash
# Check RBAC
oc get clusterrole | grep seawise
oc get clusterrolebinding | grep seawise

# Check ServiceAccount
oc get sa -n seawise-app
```

**Solution:** The Helm chart automatically creates all required RBAC resources. If there are errors, reinstall:

```bash
helm uninstall seawise-dashboard -n seawise-app
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f openshift-values.yaml
```

---

### 5. Security Context Constraints (SCC) Issues

OpenShift has strict security policies. The chart uses:
- `runAsUser: 1001`
- `runAsNonRoot: true`
- No privileged containers

If you get SCC errors:

```bash
# Check SCC
oc get scc

# Describe pod to see SCC errors
oc describe pod -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
```

The default `restricted-v2` SCC should work. If not, you may need to adjust:

```bash
# Option 1: Use anyuid SCC (not recommended for production)
oc adm policy add-scc-to-user anyuid -z seawise-dashboard -n seawise-app

# Option 2: Adjust runAsUser in values
# Edit openshift-values.yaml and remove or adjust runAsUser
```

---

## 🔄 Update to New Version

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --reuse-values
```

---

## 🗑️ Uninstall

```bash
# Remove application
helm uninstall seawise-dashboard -n seawise-app

# Remove data (CAUTION: this deletes the database!)
oc delete pvc -n seawise-app seawise-dashboard-pvc

# Remove namespace
oc delete project seawise-app
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
cat > openshift-values.yaml <<'YAML'
image:
  repository: shwcloud/seawise-backup
  tag: "v1.5.0"
  pullPolicy: IfNotPresent
app:
  veleroNamespace: "openshift-adp"
  timezone: "America/Sao_Paulo"
persistence:
  enabled: true
  storageClassName: "nfs-storage-class"
  size: 1Gi
route:
  enabled: true
  host: ""
  tls:
    enabled: true
    termination: edge
ingress:
  enabled: false
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
podSecurityContext:
  fsGroup: 1001
  runAsNonRoot: true
  runAsUser: 1001
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1001
YAML

# 2. EDIT storage class if needed
nano openshift-values.yaml

# 3. Install
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.3/seawise-dashboard-1.5.3.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f openshift-values.yaml

# 4. Verify
oc get pods,route -n seawise-app

# 5. Get URL
oc get route -n seawise-app seawise-dashboard -o jsonpath='{.spec.host}'
echo ""
```

**Done! 🎉**

---

## 💡 Pro Tips

### Quick OADP Status Check

```bash
# Check OADP operator
oc get csv -n openshift-adp | grep oadp

# Check DataProtectionApplication
oc get dpa -n openshift-adp

# Check Velero deployment
oc get deployment -n openshift-adp velero
```

### View Dashboard Without Route (Testing)

```bash
oc port-forward -n seawise-app svc/seawise-dashboard 8080:80
# Access: http://localhost:8080
```

### Export Route URL

```bash
export SEAWISE_URL=$(oc get route -n seawise-app seawise-dashboard -o jsonpath='{.spec.host}')
echo "Access Seawise Dashboard at: https://$SEAWISE_URL"
```

---

**Ready to backup! 🚀**
