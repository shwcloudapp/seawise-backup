# 🚀 Seawise Backup Dashboard - Helm Charts

Este diretório contém o Helm chart oficial para instalar o **Seawise Backup Dashboard** em ambientes Kubernetes, Rancher e OpenShift.

## 📦 O que é o Seawise Backup Dashboard?

Seawise Backup Dashboard é uma interface web moderna e intuitiva para gerenciar operações de backup e restore usando Velero/OADP em clusters Kubernetes, Rancher e OpenShift.

### 🌟 Principais Recursos

- ✅ **Gerenciamento Completo**: Crie, liste, delete backups e restores
- ✅ **Multi-Plataforma**: Suporte para Kubernetes, Rancher (RKE/RKE2) e OpenShift (OADP)
- ✅ **Backups Agendados**: Crie políticas de backup com cron schedules
- ✅ **Backup de Volumes**: Anotação automática de pods para backup de PVCs
- ✅ **Multi-Cloud**: Gerencia Backup Storage Locations (BSL) para AWS, Azure, GCP
- ✅ **Interface Intuitiva**: UI moderna com suporte a Português e Inglês
- ✅ **Relatórios**: Gere relatórios em PDF das operações de backup
- ✅ **Autenticação**: Sistema de login com controle de acesso por roles

## 🚀 Quick Start

### 1. Instalar Velero/OADP

Antes de instalar o Dashboard, certifique-se de ter o Velero/OADP instalado no cluster.

📖 **Guia completo**: [docs/instalacao_velero_completa.md](../docs/instalacao_velero_completa.md)

### 2. Instalar o Seawise Dashboard

#### **⚡ RECOMENDADO: Instalação Direta da Release**

**Não precisa clonar o repositório!**

**Kubernetes/Rancher:**
```bash
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace
```

**OpenShift:**
```bash
helm install seawise-dashboard \
  https://github.com/shwcloudapp/seawise-backup/releases/download/v1.5.0/seawise-dashboard-1.5.0.tgz \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set route.tls.enabled=true
```

#### **Opção Alternativa: Clonar Repositório**

```bash
# Clonar repositório
git clone https://github.com/shwcloudapp/seawise-backup.git
cd seawise-backup/helm-chart

# Instalar
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace
```

### 3. Acessar o Dashboard

```bash
# Port forward para acesso local
kubectl port-forward -n seawise-app svc/seawise-dashboard 8080:80

# Abrir navegador: http://localhost:8080
```

📖 **Guia completo para usuários**: [USER-INSTALL-GUIDE.md](USER-INSTALL-GUIDE.md)

## 📚 Documentação Completa

- 🚀 **[Guia de Instalação para Usuários](USER-INSTALL-GUIDE.md)**: Guia completo e simplificado para instalar via release
- 🐄 **[Instalação no Rancher](RANCHER-INSTALL.md)**: Guia específico para clusters Rancher com Traefik
- 📖 **[Guia Rápido](QUICK-START.md)**: Comece em 5 minutos
- 📖 **[Helm Chart README](seawise-dashboard/README.md)**: Documentação completa do chart
- 📖 **[Guia de Instalação Detalhado](seawise-dashboard/INSTALL.md)**: Instruções técnicas com troubleshooting
- 📖 **[Instalação Velero](../docs/instalacao_velero_completa.md)**: Como instalar Velero/OADP
- 📖 **[Exemplos de Valores](seawise-dashboard/values-examples/)**: Configurações prontas para diferentes cenários

## 🎯 Exemplos Rápidos

### Rancher com Traefik

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  -f seawise-dashboard/values-examples/rancher-example.yaml
```

### OpenShift com OADP

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  -f seawise-dashboard/values-examples/openshift-example.yaml
```

### Kubernetes com NGINX Ingress

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  -f seawise-dashboard/values-examples/kubernetes-example.yaml
```

## ⚙️ Configurações Principais

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `image.repository` | Repositório Docker | `shwcloud/seawise-backup` |
| `image.tag` | Versão da imagem | `v1.5.0` |
| `app.veleroNamespace` | Namespace do Velero | `velero` |
| `persistence.enabled` | Habilitar PVC | `true` |
| `ingress.enabled` | Habilitar Ingress (K8s/Rancher) | `false` |
| `route.enabled` | Habilitar Route (OpenShift) | `false` |

📖 **Lista completa**: Ver [values.yaml](seawise-dashboard/values.yaml)

## 🔄 Atualização

```bash
# Atualizar para nova versão
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --set image.tag=v1.6.0
```

## 🗑️ Desinstalação

```bash
# Remover o chart
helm uninstall seawise-dashboard -n seawise-app

# Remover PVC (opcional - CUIDADO: apaga o banco de dados!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc
```

## 🏗️ Estrutura do Chart

```
seawise-dashboard/
├── Chart.yaml                 # Metadados do chart
├── values.yaml                # Valores configuráveis
├── README.md                  # Documentação do chart
├── INSTALL.md                 # Guia de instalação completo
├── .helmignore                # Arquivos ignorados no pacote
├── templates/                 # Templates Kubernetes
│   ├── NOTES.txt             # Mensagem pós-instalação
│   ├── _helpers.tpl          # Funções auxiliares
│   ├── deployment.yaml       # Deployment do app
│   ├── service.yaml          # Service
│   ├── ingress.yaml          # Ingress (K8s/Rancher)
│   ├── route.yaml            # Route (OpenShift)
│   ├── pvc.yaml              # PersistentVolumeClaim
│   ├── serviceaccount.yaml   # ServiceAccount
│   ├── clusterrole.yaml      # ClusterRole (RBAC)
│   ├── clusterrolebinding.yaml # ClusterRoleBinding
│   ├── role.yaml             # Role no namespace Velero
│   └── rolebinding.yaml      # RoleBinding
└── values-examples/           # Exemplos de configuração
    ├── rancher-example.yaml
    ├── openshift-example.yaml
    └── kubernetes-example.yaml
```

## 🧪 Validação

```bash
# Validar sintaxe
helm lint ./seawise-dashboard

# Renderizar templates (dry-run)
helm template seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --debug

# Testar instalação sem aplicar
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --dry-run --debug
```

## 📦 Empacotar Chart

```bash
# Criar pacote .tgz
helm package ./seawise-dashboard

# Resultado: seawise-dashboard-1.5.0.tgz
```

## 🆘 Precisa de Ajuda?

- 📖 **Documentação**: [Guia de Instalação Completo](seawise-dashboard/INSTALL.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/shwcloudapp/seawise-backup/issues)
- 💬 **Discussões**: [GitHub Discussions](https://github.com/shwcloudapp/seawise-backup/discussions)

## 🤝 Contribuindo

Contribuições são bem-vindas! Veja nosso [guia de contribuição](../CONTRIBUTING.md).

## 📄 Licença

Apache License 2.0 - veja [LICENSE](../LICENSE) para detalhes.

---

**Desenvolvido com ❤️ pela equipe Seawise**
