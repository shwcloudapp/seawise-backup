# ⚡ Quick Start Guide - Seawise Backup Dashboard

Guia rápido para começar a usar o Seawise Backup Dashboard em 5 minutos!

## 📋 Pré-requisitos Essenciais

- ✅ Cluster Kubernetes/Rancher/OpenShift funcionando
- ✅ `kubectl` ou `oc` configurado
- ✅ Helm 3.x instalado
- ✅ Velero/OADP já instalado no cluster

> **Não tem Velero?** Veja: [docs/instalacao_velero_completa.md](../docs/instalacao_velero_completa.md)

---

## 🚀 Instalação em 3 Passos

### **Opção 1: Rancher/Kubernetes**

```bash
# 1. Clone o repositório
git clone https://github.com/shwcloudapp/seawise-backup.git
cd seawise-backup/helm-chart

# 2. Instale o chart
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=seawise.SEU-IP.sslip.io

# 3. Acesse via port-forward ou Ingress
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80
# Abra: http://localhost:8080
```

### **Opção 2: OpenShift**

```bash
# 1. Clone o repositório
git clone https://github.com/shwcloudapp/seawise-backup.git
cd seawise-backup/helm-chart

# 2. Instale com Route do OpenShift
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set route.tls.enabled=true

# 3. Obtenha a URL da Route
oc get route -n seawise-app seawise-dashboard
# Acesse a URL retornada
```

---

## 🎯 Comandos Úteis

### Verificar Status

```bash
# Ver pods
kubectl get pods -n seawise-app

# Ver logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f

# Status geral
helm status seawise-dashboard -n seawise-app
```

### Atualizar Configuração

```bash
# Atualizar com novo valor
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set app.timezone="America/Sao_Paulo" \
  --reuse-values

# Atualizar com arquivo de valores
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  -f meus-valores.yaml
```

### Desinstalar

```bash
# Remover aplicação
helm uninstall seawise-dashboard -n seawise-app

# Remover PVC (CUIDADO: apaga dados!)
kubectl delete pvc -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
```

---

## 🔧 Configurações Rápidas

### Habilitar Ingress com Domínio Próprio

```bash
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=backup.exemplo.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --reuse-values
```

### Configurar Timezone

```bash
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set app.timezone="America/Sao_Paulo" \
  --reuse-values
```

### Aumentar Recursos

```bash
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=1Gi \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi \
  --reuse-values
```

---

## 🐛 Troubleshooting Rápido

### Pod não inicia

```bash
# Ver detalhes do pod
kubectl describe pod -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Ver logs com erro
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard --previous
```

**Causa comum**: PVC não está bound.

```bash
# Verificar PVC
kubectl get pvc -n seawise-app
kubectl describe pvc -n seawise-app seawise-dashboard-pvc
```

### "Velero not found" no Dashboard

**Solução**: Corrigir namespace do Velero

```bash
# Descobrir namespace correto
kubectl get deployment --all-namespaces | grep velero

# Atualizar
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set app.veleroNamespace=NAMESPACE-CORRETO \
  --reuse-values
```

### Erro de permissão ao criar backup

```bash
# Verificar RBAC
kubectl get clusterrole | grep seawise
kubectl get clusterrolebinding | grep seawise

# Reinstalar RBAC
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set rbac.create=true \
  --reuse-values
```

---

## 📚 Próximos Passos

1. ✅ **Configure o setup inicial** no primeiro acesso
2. ✅ **Crie seu primeiro backup** via Dashboard
3. ✅ **Configure backup schedules** (políticas agendadas)
4. ✅ **Teste um restore** para validar

---

## 🆘 Precisa de Mais Ajuda?

- 📖 [Documentação Completa](seawise-dashboard/README.md)
- 📖 [Guia de Instalação Detalhado](seawise-dashboard/INSTALL.md)
- 🐛 [Reportar Bug](https://github.com/shwcloudapp/seawise-backup/issues)

---

**🎉 Pronto para começar! Boa sorte com seus backups!**
