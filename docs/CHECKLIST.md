# ✅ Checklist de Implantação - Seawise Backup Dashboard

Use este checklist para garantir uma instalação bem-sucedida do Seawise Dashboard.

---

## 📋 Pré-Instalação

### Ambiente
- [ ] Cluster Kubernetes/Rancher/OpenShift está funcionando
- [ ] `kubectl` ou `oc` está instalado e configurado
- [ ] Helm 3.x está instalado (`helm version`)
- [ ] Você tem permissões administrativas no cluster

### Velero/OADP
- [ ] Velero/OADP está instalado no cluster
- [ ] Você sabe qual namespace o Velero está instalado (`velero`, `openshift-adp`, etc.)
- [ ] Velero tem ao menos um Backup Storage Location (BSL) configurado
- [ ] Node Agent está rodando (para backup de volumes)

```bash
# Verificar Velero
kubectl get deployment -n velero velero
# Ou para OpenShift:
oc get deployment -n openshift-adp velero

# Verificar BSL
kubectl get backupstoragelocation -n velero
# Ou:
oc get backupstoragelocation -n openshift-adp
```

### Storage
- [ ] Cluster tem Storage Class configurado
- [ ] Storage Class suporta `ReadWriteOnce`
- [ ] Há espaço disponível para PVC de 1Gi

```bash
# Listar storage classes
kubectl get storageclass

# Ver qual é o default
kubectl get storageclass | grep default
```

---

## 🚀 Durante a Instalação

### Configuração
- [ ] Decidiu qual namespace usar (padrão: `seawise-app`)
- [ ] Configurou o namespace correto do Velero em `app.veleroNamespace`
- [ ] Definiu timezone adequado em `app.timezone`
- [ ] Gerou chave secreta do Flask (produção): `openssl rand -hex 32`
- [ ] Escolheu método de exposição:
  - [ ] Port Forward (desenvolvimento)
  - [ ] Ingress (Kubernetes/Rancher)
  - [ ] Route (OpenShift)

### Valores Customizados (opcional)
- [ ] Criou arquivo `custom-values.yaml` com suas configurações
- [ ] Definiu storage class se não usar o default
- [ ] Configurou recursos (CPU/memória) adequados
- [ ] Configurou Ingress hostname ou Route host

### Comando de Instalação
- [ ] Executou comando helm install apropriado para seu ambiente
- [ ] Não houve erros durante a instalação

```bash
# Exemplo Rancher/Kubernetes
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  -f custom-values.yaml

# Exemplo OpenShift
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  -f custom-values.yaml
```

---

## ✅ Pós-Instalação

### Verificação de Recursos

#### Namespace
- [ ] Namespace foi criado
```bash
kubectl get namespace seawise-app
```

#### Deployment
- [ ] Deployment foi criado
- [ ] Deployment está pronto (READY 1/1)
```bash
kubectl get deployment -n seawise-app
```

#### Pods
- [ ] Pod está em estado `Running`
- [ ] Pod não está em `CrashLoopBackOff` ou `Error`
- [ ] Container está pronto (READY 1/1)
```bash
kubectl get pods -n seawise-app
kubectl describe pod -n seawise-app -l app.kubernetes.io/name=seawise-dashboard
```

#### PVC
- [ ] PVC foi criado
- [ ] PVC está em estado `Bound`
```bash
kubectl get pvc -n seawise-app
```

#### Service
- [ ] Service foi criado
- [ ] Service tem ClusterIP atribuído
```bash
kubectl get svc -n seawise-app
```

#### RBAC
- [ ] ServiceAccount foi criado
- [ ] ClusterRole foi criado
- [ ] ClusterRoleBinding foi criado
- [ ] Role no namespace Velero foi criado (se aplicável)
- [ ] RoleBinding no namespace Velero foi criado (se aplicável)
```bash
kubectl get sa -n seawise-app
kubectl get clusterrole | grep seawise
kubectl get clusterrolebinding | grep seawise
kubectl get role -n velero | grep seawise  # Ajuste namespace se necessário
```

#### Ingress/Route
- [ ] Ingress foi criado (Kubernetes/Rancher) ou Route (OpenShift)
- [ ] Ingress/Route tem endereço atribuído
```bash
# Kubernetes/Rancher
kubectl get ingress -n seawise-app

# OpenShift
oc get route -n seawise-app
```

### Logs
- [ ] Logs do pod não mostram erros críticos
- [ ] Aplicação iniciou corretamente (procurar por mensagens de início do Flask)
```bash
kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard --tail=50
```

---

## 🌐 Acesso

### Conectividade
- [ ] Consegue acessar via port-forward
```bash
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80
# Testar: http://localhost:8080
```

- [ ] Consegue acessar via Ingress hostname (se habilitado)
- [ ] Consegue acessar via Route URL (OpenShift, se habilitado)

### Setup Inicial
- [ ] Aplicação redireciona para página de setup no primeiro acesso
- [ ] Consegue visualizar informações de detecção do cluster
- [ ] Consegue criar primeiro usuário administrador
- [ ] Consegue fazer login com credenciais criadas

### Dashboard
- [ ] Dashboard carrega corretamente após login
- [ ] Consegue ver lista de backups (se houver)
- [ ] Consegue navegar pelas páginas (Backups, Restores, etc.)
- [ ] Não há erros de JavaScript no console do navegador

---

## 🧪 Funcionalidades

### Backup
- [ ] Consegue criar um backup Fast (sob demanda)
- [ ] Backup aparece na lista após criação
- [ ] Consegue ver detalhes do backup
- [ ] Status do backup atualiza corretamente

### Restore
- [ ] Consegue criar um restore a partir de um backup
- [ ] Restore aparece na lista
- [ ] Consegue ver detalhes do restore

### Backup Schedule (Políticas)
- [ ] Consegue criar uma política de backup agendada
- [ ] Schedule aparece na lista
- [ ] Schedule cria backups automaticamente

### Storage Locations
- [ ] Consegue ver lista de Backup Storage Locations
- [ ] BSLs aparecem com status correto (Available)

### Configurações
- [ ] Consegue acessar página de configurações
- [ ] Configurações são salvas corretamente

---

## 🚨 Troubleshooting

Se algo falhou, verifique:

### Pod não inicia
- [ ] Verificou eventos do pod: `kubectl describe pod -n seawise-app`
- [ ] Verificou logs: `kubectl logs -n seawise-app -l app.kubernetes.io/name=seawise-dashboard`
- [ ] PVC está bound: `kubectl get pvc -n seawise-app`
- [ ] Storage class está disponível: `kubectl get storageclass`

### "Velero not found"
- [ ] Verificou namespace correto do Velero
- [ ] Velero está rodando: `kubectl get deployment -n NAMESPACE velero`
- [ ] RBAC correto: `kubectl get clusterrole | grep seawise`

### Erro de permissão
- [ ] ClusterRole tem permissões necessárias
- [ ] ClusterRoleBinding vincula ServiceAccount ao ClusterRole
- [ ] Role no namespace Velero existe
- [ ] RoleBinding no namespace Velero existe

### Ingress não funciona
- [ ] Ingress Controller está instalado no cluster
- [ ] Ingress tem hostname configurado
- [ ] DNS aponta para o Ingress Controller
- [ ] Testa acesso direto via port-forward funciona

---

## 📊 Resultado Final

**Status da Instalação:**
- [ ] ✅ Todos os recursos criados corretamente
- [ ] ✅ Aplicação está rodando sem erros
- [ ] ✅ Acesso via Ingress/Route/Port-Forward funciona
- [ ] ✅ Setup inicial concluído
- [ ] ✅ Funcionalidades básicas testadas e funcionando

---

## 📚 Próximos Passos

Após completar este checklist:

1. **Documentar**: Anote configurações importantes (namespace Velero, hostname Ingress, etc.)
2. **Backup**: Considere fazer backup do PVC do Seawise periodicamente
3. **Monitorar**: Configure alertas se o pod ficar indisponível
4. **Atualizar**: Planeje como fará updates do Seawise Dashboard

---

## 🆘 Precisa de Ajuda?

Se algo não funcionou:
1. Consulte [INSTALL.md](seawise-dashboard/INSTALL.md) seção "Troubleshooting"
2. Revise logs detalhadamente
3. Abra uma issue: https://github.com/shwcloudapp/seawise-backup/issues

---

**Data da Instalação**: _______________
**Responsável**: _______________
**Ambiente**: [ ] Desenvolvimento [ ] Homologação [ ] Produção
