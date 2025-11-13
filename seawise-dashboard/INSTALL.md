# 🚀 Guia de Instalação do Seawise Backup Dashboard

Este guia fornece instruções detalhadas para instalar o **Seawise Backup Dashboard** usando Helm em ambientes Kubernetes, Rancher e OpenShift.

---

## 📋 Pré-requisitos

Antes de instalar o Seawise Dashboard, certifique-se de que você tem:

### 1. **Cluster Kubernetes/Rancher/OpenShift**
- Kubernetes 1.20+ ou OpenShift 4.10+
- Acesso administrativo ao cluster via `kubectl` ou `oc`

### 2. **Helm 3.x Instalado**
```bash
# Verificar instalação do Helm
helm version

# Se não estiver instalado, instale:
# https://helm.sh/docs/intro/install/
```

### 3. **Velero ou OADP Instalado**
O Seawise Dashboard gerencia backups Velero/OADP. Certifique-se de que você já tem o Velero instalado:

```bash
# Verificar se Velero está instalado (Kubernetes/Rancher)
kubectl get deployment -n velero velero

# Verificar OADP (OpenShift)
oc get deployment -n openshift-adp velero
```

**Não tem Velero instalado?** Consulte nosso guia completo: [docs/instalacao_velero_completa.md](../../docs/instalacao_velero_completa.md)

### 4. **Storage Class Configurado**
O Seawise precisa de armazenamento persistente para o banco de dados SQLite:

```bash
# Verificar storage classes disponíveis
kubectl get storageclass

# Exemplo de saída:
# NAME                PROVISIONER
# local-path (default)   rancher.io/local-path
# nfs-storage            nfs-provisioner
```

---

## 🔧 Instalação Rápida (Kubernetes/Rancher)

### Passo 1: Adicionar o Repositório Helm (Futuro)

⚠️ **Nota**: Por enquanto, o chart não está publicado em repositório Helm. Use a instalação local abaixo.

### Passo 2: Instalação Local do Chart

```bash
# Clone ou baixe o repositório
git clone https://github.com/shwcloudapp/seawise-backup.git
cd seawise-backup/helm-chart

# Instalar com valores padrão
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace
```

### Passo 3: Verificar a Instalação

```bash
# Verificar pods
kubectl get pods -n seawise-app

# Verificar serviços
kubectl get svc -n seawise-app

# Ver logs do pod
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f
```

### Passo 4: Acessar o Dashboard

#### **Opção A: Port Forward (Teste Local)**
```bash
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80

# Acessar: http://localhost:8080
```

#### **Opção B: Ingress (Produção)**
```bash
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=seawise.seu-dominio.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

---

## 🔧 Instalação no OpenShift

### Passo 1: Instalar com OpenShift Route

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set route.tls.enabled=true \
  --set route.tls.termination=edge
```

### Passo 2: Obter a URL da Route

```bash
# Ver a URL gerada automaticamente
oc get route -n seawise-app seawise-dashboard

# Exemplo de saída:
# NAME                 HOST/PORT
# seawise-dashboard    seawise-dashboard-seawise-app.apps.cluster.example.com
```

### Passo 3: Acessar o Dashboard

Abra o navegador e acesse a URL da route obtida no passo anterior.

---

## ⚙️ Configuração Avançada

### Personalizar com `values.yaml`

Crie um arquivo `custom-values.yaml`:

```yaml
# ============================================================================
# CONFIGURAÇÃO DA IMAGEM
# ============================================================================
image:
  repository: shwcloud/seawise-backup
  tag: "v1.5.0"
  pullPolicy: IfNotPresent

# ============================================================================
# NAMESPACE DO VELERO
# ============================================================================
app:
  # Ajuste conforme seu ambiente:
  # - "velero" para Rancher/Kubernetes
  # - "openshift-adp" para OpenShift
  veleroNamespace: "velero"

  # Timezone da aplicação
  timezone: "America/Sao_Paulo"  # ou "UTC", "Europe/London", etc.

  # Chave secreta do Flask (IMPORTANTE em produção!)
  # Gerar com: openssl rand -hex 32
  secretKey: "sua-chave-secreta-aqui-64-caracteres-hexadecimais-gerados"

# ============================================================================
# PERSISTÊNCIA
# ============================================================================
persistence:
  enabled: true
  storageClassName: "local-path"  # ou "nfs-storage", "default", etc.
  size: 1Gi
  accessMode: ReadWriteOnce

# ============================================================================
# RECURSOS
# ============================================================================
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# ============================================================================
# INGRESS (Kubernetes/Rancher)
# ============================================================================
ingress:
  enabled: true
  className: "nginx"  # ou "traefik"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"  # Se usar cert-manager
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: seawise.exemplo.com.br
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: seawise-tls
      hosts:
        - seawise.exemplo.com.br

# ============================================================================
# ROUTE (OpenShift)
# ============================================================================
route:
  enabled: false  # Use true no OpenShift
  tls:
    enabled: true
    termination: edge
```

### Instalar com Valores Personalizados

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  -f custom-values.yaml
```

---

## 🔐 Configuração de Segurança

### 1. Gerar Chave Secreta do Flask

```bash
# Gerar chave segura
openssl rand -hex 32

# Usar no values.yaml:
app:
  secretKey: "a1b2c3d4e5f6...resultado-do-comando-acima"
```

### 2. Configurar RBAC (já incluído no chart)

O chart cria automaticamente:
- ✅ ServiceAccount
- ✅ ClusterRole com permissões mínimas necessárias
- ✅ ClusterRoleBinding
- ✅ Role no namespace do Velero
- ✅ RoleBinding

### 3. Configurar Network Policy (opcional)

```yaml
# Em custom-values.yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
```

---

## 🔄 Atualização

### Atualizar para Nova Versão

```bash
# Atualizar com nova imagem
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set image.tag=v1.6.0 \
  -f custom-values.yaml

# Verificar status do upgrade
helm status seawise-dashboard -n seawise-app

# Ver histórico de releases
helm history seawise-dashboard -n seawise-app
```

### Rollback

```bash
# Voltar para versão anterior
helm rollback seawise-dashboard -n seawise-app

# Ou para uma revisão específica
helm rollback seawise-dashboard 2 -n seawise-app
```

---

## 🗑️ Desinstalação

```bash
# Desinstalar o chart
helm uninstall seawise-dashboard -n seawise-app

# Remover PVC (opcional - cuidado, isso apaga o banco de dados!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc

# Remover namespace (opcional)
kubectl delete namespace seawise-app
```

---

## ✅ Verificação da Instalação

Execute este script para verificar tudo:

```bash
#!/bin/bash

echo "=========================================="
echo "🔍 VERIFICAÇÃO SEAWISE DASHBOARD"
echo "=========================================="
echo ""

echo "1️⃣ Namespace..."
kubectl get namespace seawise-app
echo ""

echo "2️⃣ Deployment..."
kubectl get deployment -n seawise-app
echo ""

echo "3️⃣ Pods..."
kubectl get pods -n seawise-app
echo ""

echo "4️⃣ Services..."
kubectl get svc -n seawise-app
echo ""

echo "5️⃣ PVC..."
kubectl get pvc -n seawise-app
echo ""

echo "6️⃣ RBAC (ServiceAccount, ClusterRole, ClusterRoleBinding)..."
kubectl get sa -n seawise-app
kubectl get clusterrole | grep seawise
kubectl get clusterrolebinding | grep seawise
echo ""

echo "7️⃣ Ingress/Route..."
kubectl get ingress -n seawise-app 2>/dev/null || echo "Ingress não habilitado"
kubectl get route -n seawise-app 2>/dev/null || echo "Route não habilitado (OpenShift)"
echo ""

echo "8️⃣ Logs recentes do pod..."
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard --tail=20
echo ""

echo "=========================================="
echo "✅ VERIFICAÇÃO COMPLETA"
echo "=========================================="
```

Salve como `verify-seawise.sh`, dê permissão e execute:

```bash
chmod +x verify-seawise.sh
./verify-seawise.sh
```

---

## 🧪 Primeiro Acesso

### 1. Acesse o Dashboard

Após instalar, acesse via:
- **Port Forward**: `http://localhost:8080`
- **Ingress**: `https://seawise.seu-dominio.com`
- **Route (OpenShift)**: URL obtida com `oc get route`

### 2. Setup Inicial

Na primeira vez, você será redirecionado para a página de setup:
- Configure o namespace do Velero (se não detectado automaticamente)
- Crie o primeiro usuário administrador
- Configure timezone e preferências

### 3. Login

Use as credenciais criadas no setup inicial para fazer login.

---

## 🚨 Troubleshooting

### Problema: Pod não inicia (CrashLoopBackOff)

```bash
# Ver logs do pod
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Possíveis causas:
# - PVC não montado corretamente
# - Falta de permissões RBAC
# - Imagem não encontrada
```

**Solução**: Verifique se o PVC está bound:
```bash
kubectl get pvc -n seawise-app

# Se estiver Pending, verifique o storage class
kubectl describe pvc -n seawise-app seawise-dashboard-pvc
```

### Problema: "Velero not found" no Dashboard

**Causa**: Namespace do Velero incorreto ou Velero não instalado.

**Solução**:
```bash
# Verificar onde o Velero está instalado
kubectl get deployment --all-namespaces | grep velero

# Atualizar o chart com namespace correto
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set app.veleroNamespace=nome-correto-do-namespace \
  --reuse-values
```

### Problema: Erro de permissão ao criar backup

**Causa**: RBAC insuficiente.

**Solução**: Verificar ClusterRole e ClusterRoleBinding:
```bash
kubectl describe clusterrole seawise-dashboard-manager
kubectl describe clusterrolebinding seawise-dashboard-manager-binding
```

### Problema: Ingress não funciona

**Solução**:
```bash
# Verificar se o Ingress Controller está instalado
kubectl get pods -n kube-system | grep ingress

# Verificar o Ingress criado
kubectl describe ingress -n seawise-app seawise-dashboard

# Testar acesso direto ao Service
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80
```

---

## 📚 Próximos Passos

Após a instalação bem-sucedida:

1. **Configure Velero/OADP** (se ainda não fez): [docs/instalacao_velero_completa.md](../../docs/instalacao_velero_completa.md)
2. **Crie seu primeiro backup** via Dashboard
3. **Configure backup schedules** (políticas de backup agendadas)
4. **Teste restore** para validar seus backups

---

## 🆘 Suporte

- **GitHub Issues**: https://github.com/shwcloudapp/seawise-backup/issues
- **Documentação**: https://github.com/shwcloudapp/seawise-backup/tree/main/docs

---

**Pronto! Seu Seawise Backup Dashboard está instalado e pronto para uso! 🎉**
