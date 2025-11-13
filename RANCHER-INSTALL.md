# 🚀 Instalação no Rancher - Guia Simplificado

Guia rápido e fácil para instalar o Seawise Dashboard em clusters Rancher.

---

## ✅ Antes de Começar

Você precisa ter:
- ✅ Cluster Rancher funcionando (RKE/RKE2/K3s)
- ✅ Velero instalado (geralmente no namespace `velero`)
- ✅ Acesso kubectl ou oc configurado

---

## 🎯 Instalação em 3 Passos

### Passo 1: Descobrir o IP do Cluster

```bash
kubectl get nodes -o wide
```

Anote o **IP INTERNO** de qualquer node (exemplo: `192.168.100.97`)

---

### Passo 2: Criar Arquivo de Configuração

**Copie e cole este comando** (vai criar o arquivo automaticamente):

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

**Agora edite o IP:**

```bash
# Substitua 192.168.100.97 pelo IP do seu cluster
sed -i 's/192.168.100.97/SEU_IP_AQUI/g' rancher-values.yaml

# Ou edite manualmente:
nano rancher-values.yaml
# Altere as linhas 18 e 23
```

---

### Passo 3: Instalar

```bash
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-values.yaml
```

**Pronto!** Aguarde 1-2 minutos e acesse:

```
https://seawise-backup.SEU-IP.sslip.io
```

---

## 🔍 Verificar se Funcionou

```bash
# Ver se o pod está rodando
kubectl get pods -n seawise-app

# Ver o Ingress
kubectl get ingress -n seawise-app

# Ver logs (se necessário)
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f
```

**Saída esperada:**

```
NAME                                 READY   STATUS    RESTARTS   AGE
seawise-dashboard-xxxxxxxxxx-xxxxx   1/1     Running   0          2m

NAME                CLASS     HOSTS                                   PORTS     AGE
seawise-dashboard   traefik   seawise-backup.192.168.100.97.sslip.io   80, 443   2m
```

---

## 🌐 Se Você Usa NGINX ao Invés de Traefik

Se o seu Rancher usa NGINX Ingress Controller, use este arquivo:

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

# Editar o IP
sed -i 's/192.168.100.97/SEU_IP_AQUI/g' rancher-nginx-values.yaml

# Instalar
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-nginx-values.yaml
```

---

## ⚙️ Configurações Comuns

### Alterar Timezone

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.timezone="America/New_York"
```

### Usar Domínio Próprio

Se você tem um domínio (exemplo: `backup.minhaempresa.com`):

```bash
# Editar o arquivo
nano rancher-values.yaml

# Alterar:
# hosts:
#   - host: backup.minhaempresa.com

# Atualizar
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  -f rancher-values.yaml
```

### Alterar Namespace do Velero

Se o Velero estiver em outro namespace:

```bash
# Descobrir
kubectl get deployment --all-namespaces | grep velero

# Atualizar
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="cattle-velero"
```

---

## 🐛 Problemas Comuns

### 1. Pod não inicia (CrashLoopBackOff)

```bash
# Ver logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Verificar PVC
kubectl get pvc -n seawise-app
```

**Solução:** Geralmente é problema de storage. Verifique se a StorageClass existe:

```bash
kubectl get storageclass
```

Se não tiver `local-path`, use outra (exemplo: `default`, `nfs-client`):

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set persistence.storageClassName="default"
```

---

### 2. Ingress não aparece / URL não funciona

```bash
# Verificar qual Ingress Controller está instalado
kubectl get pods -n kube-system | grep -E "traefik|nginx"

# Verificar o Ingress criado
kubectl describe ingress -n seawise-app seawise-dashboard
```

**Soluções:**

- **Traefik não instalado?** Use a configuração NGINX acima
- **IP errado?** Verifique o IP com `kubectl get nodes -o wide`
- **Firewall?** Teste com port-forward: `kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80`

---

### 3. "Velero not found" no Dashboard

```bash
# Descobrir onde o Velero está
kubectl get deployment --all-namespaces | grep velero

# Se estiver em outro namespace, atualize:
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="NAMESPACE-CORRETO"
```

---

### 4. Certificado SSL inválido

Isso é **normal** com sslip.io! O Traefik gera certificado autoassinado.

**Soluções:**

1. **Aceite o certificado** no navegador (clique "Avançado" → "Continuar")
2. **Use cert-manager** para certificados Let's Encrypt reais
3. **Use domínio próprio** com SSL configurado

---

## 🔄 Atualizar para Nova Versão

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --reuse-values
```

---

## 🗑️ Desinstalar

```bash
# Remover aplicação
helm uninstall seawise-dashboard -n seawise-app

# Remover dados (CUIDADO: apaga o banco!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc

# Remover namespace
kubectl delete namespace seawise-app
```

---

## 🆘 Precisa de Ajuda?

- 📖 [Documentação Completa](README.md)
- 📖 [Guia Geral](USER-INSTALL-GUIDE.md)
- 🐛 [Reportar Problema](https://github.com/shwcloudapp/seawise-backup/issues)

---

## 📋 Resumo do Comando Completo

Para facilitar, aqui está o comando completo em um único bloco:

```bash
# 1. Criar arquivo de configuração
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

# 2. EDITE O IP (altere 192.168.100.97 para o IP do seu cluster)
nano rancher-values.yaml

# 3. Instalar
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.2/seawise-dashboard-1.5.2.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-values.yaml

# 4. Verificar
kubectl get pods,ingress -n seawise-app

# 5. Acessar
echo "Acesse: https://seawise-backup.SEU-IP.sslip.io"
```

**Pronto! 🎉**
