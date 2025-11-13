# 🚀 Instalação no Rancher - Guia Rápido

Guia específico para instalar o Seawise Dashboard em clusters Rancher com Traefik.

---

## ✅ Pré-requisitos

- Cluster Rancher (RKE/RKE2) funcionando
- Velero instalado no namespace `velero`
- Acesso kubectl configurado

---

## 🎯 Instalação Rápida (Método 1 - Recomendado)

### 1. Descubra o IP do seu cluster

```bash
# Método 1: Ver IP do load balancer
kubectl get svc -n kube-system traefik

# Método 2: Ver IP de um node
kubectl get nodes -o wide
```

Anote o IP (exemplo: `192.168.100.97`)

### 2. Instalar com um único comando

```bash
# ALTERE O IP ABAIXO para o IP do seu cluster!
export CLUSTER_IP="192.168.100.97"

helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.annotations."kubernetes\.io/ingress\.allow-http"="false" \
  --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.entrypoints"="web,websecure" \
  --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.tls"="true" \
  --set ingress.hosts[0].host="seawise-backup.${CLUSTER_IP}.sslip.io" \
  --set ingress.hosts[0].paths[0].path="/" \
  --set ingress.hosts[0].paths[0].pathType="Prefix" \
  --set-string ingress.tls[0].hosts[0]="seawise-backup.${CLUSTER_IP}.sslip.io" \
  --set persistence.storageClassName="local-path"
```

### 3. Aguardar o pod iniciar

```bash
# Ver status
kubectl get pods -n seawise-app -w

# Aguarde até aparecer: Running (pode demorar 1-2 minutos)
```

### 4. Obter a URL de acesso

```bash
kubectl get ingress -n seawise-app seawise-dashboard
```

**URL de acesso:**
```
https://seawise-backup.192.168.100.97.sslip.io
```

Abra no navegador! 🎉

---

## 🎯 Instalação com Arquivo de Valores (Método 2)

### 1. Criar arquivo `rancher-values.yaml`

```bash
cat > rancher-values.yaml <<EOF
app:
  veleroNamespace: "velero"
  timezone: "America/Sao_Paulo"

persistence:
  enabled: true
  storageClassName: "local-path"
  size: 1Gi

ingress:
  enabled: true
  className: ""
  annotations:
    kubernetes.io/ingress.allow-http: "false"
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
  hosts:
    - host: seawise-backup.192.168.100.97.sslip.io  # ALTERE ESTE IP!
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - seawise-backup.192.168.100.97.sslip.io  # ALTERE ESTE IP!

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
```

**⚠️ IMPORTANTE:** Edite o arquivo e altere os dois IPs (linhas 16 e 21) para o IP do seu cluster!

### 2. Instalar

```bash
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace \
  -f rancher-values.yaml
```

---

## 🔍 Verificar Instalação

```bash
# Ver todos os recursos
kubectl get all -n seawise-app

# Ver Ingress (deve mostrar o host)
kubectl get ingress -n seawise-app

# Ver logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard -f

# Status do Helm
helm status seawise-dashboard -n seawise-app
```

**Saída esperada do Ingress:**
```
NAME                CLASS    HOSTS                                      ADDRESS   PORTS     AGE
seawise-dashboard   <none>   seawise-backup.192.168.100.97.sslip.io              80, 443   2m
```

---

## 🌐 Acessar o Dashboard

### Via Ingress (URL externa)

Acesse: `https://seawise-backup.SEU-IP.sslip.io`

### Via Port Forward (alternativa)

```bash
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80

# Acesse: http://localhost:8080
```

---

## ⚙️ Configurações Comuns

### Alterar o domínio após instalação

```bash
# Exemplo: mudar para outro IP
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set ingress.hosts[0].host="seawise-backup.192.168.100.50.sslip.io" \
  --set-string ingress.tls[0].hosts[0]="seawise-backup.192.168.100.50.sslip.io"
```

### Usar domínio próprio (sem sslip.io)

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set ingress.hosts[0].host="backup.meudominio.com" \
  --set-string ingress.tls[0].hosts[0]="backup.meudominio.com"
```

### Habilitar cert-manager (HTTPS real)

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-prod" \
  --set ingress.tls[0].secretName="seawise-tls" \
  --set ingress.hosts[0].host="backup.meudominio.com" \
  --set-string ingress.tls[0].hosts[0]="backup.meudominio.com"
```

### Alterar namespace do Velero

Se o Velero estiver em outro namespace:

```bash
# Descobrir namespace do Velero
kubectl get deployment --all-namespaces | grep velero

# Atualizar
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="SEU-NAMESPACE"
```

---

## 🐛 Troubleshooting

### Problema 1: Ingress não aparece

```bash
# Verificar se o Ingress foi criado
kubectl describe ingress -n seawise-app seawise-dashboard

# Verificar Traefik
kubectl get pods -n kube-system | grep traefik
```

**Solução:** Certifique-se de que `ingress.enabled=true` foi passado na instalação.

### Problema 2: URL não funciona (404 ou timeout)

```bash
# Verificar se o service está funcionando
kubectl get svc -n seawise-app
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80

# Se o port-forward funciona (http://localhost:8080), o problema é no Ingress
```

**Soluções:**
1. Verifique o IP usado no sslip.io
2. Teste o IP do cluster: `curl http://SEU-IP`
3. Verifique regras de firewall

### Problema 3: Pod não inicia (CrashLoopBackOff)

```bash
# Ver logs
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard

# Ver eventos
kubectl describe pod -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
```

**Causas comuns:**
- PVC não bound (verificar: `kubectl get pvc -n seawise-app`)
- Storage class não existe (verificar: `kubectl get storageclass`)

### Problema 4: "Velero not found" no Dashboard

```bash
# Verificar namespace do Velero
kubectl get deployment --all-namespaces | grep velero

# Se estiver em namespace diferente de "velero", atualize:
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --reuse-values \
  --set app.veleroNamespace="NAMESPACE-CORRETO"
```

### Problema 5: Certificado SSL inválido

Isso é normal com sslip.io! O Traefik gera um certificado autoassinado.

**Soluções:**
1. **Aceite o certificado** no navegador (clique "Avançado" → "Continuar")
2. **Use cert-manager** para certificados Let's Encrypt (veja seção acima)
3. **Use port-forward** para teste sem SSL

---

## 🔄 Atualizar para Nova Versão

```bash
helm upgrade seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.6.0/seawise-dashboard-1.6.0.tgz \
  --namespace seawise-app \
  --reuse-values
```

---

## 🗑️ Desinstalar

```bash
# Remover aplicação
helm uninstall seawise-dashboard -n seawise-app

# Remover PVC (CUIDADO: apaga dados!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc

# Remover namespace
kubectl delete namespace seawise-app
```

---

## 📚 Links Úteis

- [Documentação Completa](README.md)
- [Guia Geral de Instalação](USER-INSTALL-GUIDE.md)
- [Troubleshooting Detalhado](seawise-dashboard/INSTALL.md)
- [GitHub Releases](https://github.com/shwcloudapp/seawise-backup/releases)

---

## 💡 Dica: Exemplo Completo de Comando

Copie e cole (alterando apenas o IP):

```bash
export CLUSTER_IP="192.168.100.97"  # <-- ALTERE AQUI

helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.annotations."kubernetes\.io/ingress\.allow-http"="false" \
  --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.entrypoints"="web,websecure" \
  --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.tls"="true" \
  --set ingress.hosts[0].host="seawise-backup.${CLUSTER_IP}.sslip.io" \
  --set ingress.hosts[0].paths[0].path="/" \
  --set ingress.hosts[0].paths[0].pathType="Prefix" \
  --set-string ingress.tls[0].hosts[0]="seawise-backup.${CLUSTER_IP}.sslip.io" \
  --set persistence.storageClassName="local-path" \
  --set app.veleroNamespace="velero"

# Aguarde 1-2 minutos e acesse:
echo "Acesse: https://seawise-backup.${CLUSTER_IP}.sslip.io"
```

**Pronto! 🎉**
