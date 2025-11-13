# 📦 Guia de Instalação - Seawise Dashboard

Guia completo para usuários instalarem o Seawise Dashboard em qualquer ambiente Kubernetes.

---

## 📋 Pré-requisitos

Antes de instalar, você precisa ter:

- ✅ **Cluster Kubernetes, Rancher ou OpenShift** (v1.20+)
- ✅ **Helm 3.8+** instalado ([guia de instalação](https://helm.sh/docs/intro/install/))
- ✅ **kubectl** ou **oc** configurado para acessar seu cluster
- ✅ **Velero ou OADP** já instalado no cluster

> **Não tem Velero?** Instale primeiro: [Guia de instalação do Velero](https://velero.io/docs/v1.12/basic-install/)

---

## 🚀 Método 1: Instalação Direta (Recomendado)

**Mais rápido! Não precisa clonar o repositório.**

### Para Kubernetes/Rancher:

```bash
# Baixar e instalar em um único comando
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=seawise.SEU-IP.sslip.io

# Acessar via port-forward
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80
# Abra: http://localhost:8080
```

### Para OpenShift:

```bash
# Baixar e instalar com Route do OpenShift
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set route.tls.enabled=true

# Obter URL da aplicação
oc get route -n seawise-app seawise-dashboard
```

---

## 🚀 Método 2: Instalação Clonando o Repositório

### Passo 1: Clonar o repositório

```bash
git clone https://github.com/shwcloudapp/seawise-backup.git
cd seawise-backup/helm-chart
```

### Passo 2: Instalar

**Kubernetes/Rancher:**
```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace
```

**OpenShift:**
```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set route.tls.enabled=true
```

---

## 🎯 Verificar Instalação

```bash
# Verificar se o pod está rodando
kubectl get pods -n seawise-app

# Ver logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f

# Status geral
helm status seawise-dashboard -n seawise-app
```

**Saída esperada:**
```
NAME                                 READY   STATUS    RESTARTS   AGE
seawise-dashboard-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
```

---

## 🌐 Acessar o Dashboard

### Opção 1: Port Forward (Teste Rápido)

```bash
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80
```
Acesse: **http://localhost:8080**

### Opção 2: Ingress (Produção - Kubernetes/Rancher)

```bash
# Configurar com seu domínio
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=backup.exemplo.com \
  --reuse-values
```

### Opção 3: Route (OpenShift)

```bash
# Obter URL automática da Route
oc get route -n seawise-app seawise-dashboard

# Exemplo de saída:
# seawise-dashboard-seawise-app.apps.cluster.exemplo.com
```

---

## ⚙️ Configurações Importantes

### Configurar Namespace do Velero

Se o Velero estiver em um namespace diferente:

```bash
# Descobrir namespace do Velero
kubectl get deployment --all-namespaces | grep velero

# Atualizar configuração
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --set app.veleroNamespace=SEU-NAMESPACE \
  --reuse-values
```

### Configurar Timezone

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --set app.timezone="America/Sao_Paulo" \
  --reuse-values
```

### Configurar Domínio com TLS

Crie um arquivo `my-values.yaml`:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: backup.exemplo.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: seawise-tls
      hosts:
        - backup.exemplo.com
```

Aplique:
```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  -f my-values.yaml \
  --reuse-values
```

---

## 🔐 Primeiro Acesso

1. **Acesse o Dashboard** usando uma das opções acima
2. **Tela de Setup**: Na primeira vez, você será redirecionado para configuração inicial
3. **Crie usuário admin**: Defina username e senha
4. **Configure preferências**: Namespace do Velero, timezone, etc.
5. **Login**: Use as credenciais criadas

---

## 🔄 Atualizar para Nova Versão

```bash
# Atualizar para v1.6.0 (quando disponível)
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.6.0/seawise-dashboard-1.6.0.tgz \
  --namespace seawise-app \
  --reuse-values

# Verificar atualização
kubectl get pods -n seawise-app
helm history seawise-dashboard -n seawise-app
```

---

## 🗑️ Desinstalar

```bash
# Remover aplicação
helm uninstall seawise-dashboard -n seawise-app

# Remover dados (CUIDADO: isso apaga o banco de dados!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc

# Remover namespace
kubectl delete namespace seawise-app
```

---

## 🐛 Problemas Comuns

### Pod não inicia (CrashLoopBackOff)

```bash
# Ver logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Verificar PVC
kubectl get pvc -n seawise-app
kubectl describe pvc -n seawise-app seawise-dashboard-pvc
```

**Solução**: Certifique-se de que você tem um StorageClass configurado.

### "Velero not found" no Dashboard

```bash
# Verificar onde o Velero está instalado
kubectl get deployment --all-namespaces | grep velero

# Atualizar namespace correto
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --set app.veleroNamespace=NAMESPACE-CORRETO \
  --reuse-values
```

### Erro de permissão ao criar backup

```bash
# Verificar RBAC
kubectl get clusterrole | grep seawise
kubectl get clusterrolebinding | grep seawise

# Se não existir, reinstale o chart com RBAC habilitado
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --set rbac.create=true \
  --reuse-values
```

### Ingress não responde

```bash
# Verificar Ingress Controller
kubectl get pods -n kube-system | grep ingress

# Verificar configuração do Ingress
kubectl describe ingress -n seawise-app seawise-dashboard
```

---

## 📚 Documentação Adicional

- 📖 [Guia Rápido (QUICK-START.md)](QUICK-START.md)
- 📖 [Guia de Instalação Detalhado (INSTALL.md)](seawise-dashboard/INSTALL.md)
- 📖 [README do Chart](seawise-dashboard/README.md)
- 📖 [Exemplos de Values](seawise-dashboard/values-examples/)

---

## 📦 Todas as Releases

Veja todas as versões disponíveis:
**https://github.com/shwcloudapp/seawise-backup/releases**

---

## 🆘 Suporte

- 🐛 **Reportar bugs**: https://github.com/shwcloudapp/seawise-backup/issues
- 💬 **Discussões**: https://github.com/shwcloudapp/seawise-backup/discussions
- 📧 **Email**: suporte@exemplo.com

---

## 🎉 Pronto!

Agora você pode:
1. ✅ Criar backups sob demanda
2. ✅ Agendar políticas de backup (schedules)
3. ✅ Restaurar backups existentes
4. ✅ Gerenciar Storage Locations
5. ✅ Visualizar métricas e relatórios

**Boa sorte com seus backups! 🚀**
