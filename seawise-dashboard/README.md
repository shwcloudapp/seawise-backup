# Seawise Backup Dashboard - Helm Chart

![Version: 1.5.0](https://img.shields.io/badge/Version-1.5.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 1.5.0](https://img.shields.io/badge/AppVersion-1.5.0-informational?style=flat-square)

**Seawise Backup Dashboard** é uma interface web moderna para gerenciar backups e restores com Velero/OADP em ambientes Kubernetes, Rancher e OpenShift.

## 🌟 Principais Recursos

- ✅ Gerenciamento completo de backups e restores Velero/OADP
- ✅ Suporte para Kubernetes, Rancher e OpenShift (OADP)
- ✅ Interface web intuitiva em Português e Inglês
- ✅ Criação de backups sob demanda (Fast Backup)
- ✅ Políticas de backup agendadas (Schedules)
- ✅ Gerenciamento de Backup Storage Locations (BSL)
- ✅ Anotação automática de pods para backup de volumes
- ✅ Detecção automática do tipo de cluster e versão do Velero
- ✅ Relatórios em PDF de operações de backup
- ✅ Sistema de autenticação com controle de acesso (admin/backup/viewer)

## 📋 Pré-requisitos

- Kubernetes 1.20+ ou OpenShift 4.10+
- Helm 3.x
- Velero 1.9+ ou OADP 1.0+ instalado no cluster
- Storage class configurado para persistência

## 🚀 Instalação Rápida

```bash
# Adicionar repositório (futuro)
# helm repo add seawise https://shwcloudapp.github.io/seawise-backup

# Instalar localmente
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace
```

Para instruções detalhadas, consulte [INSTALL.md](INSTALL.md).

## ⚙️ Configuração

### Valores Principais

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `image.repository` | Repositório da imagem Docker | `shwcloud/seawise-backup` |
| `image.tag` | Tag da imagem | `v1.5.0` |
| `image.pullPolicy` | Política de pull da imagem | `IfNotPresent` |
| `app.veleroNamespace` | Namespace onde Velero/OADP está instalado | `velero` |
| `app.timezone` | Timezone da aplicação | `UTC` |
| `app.secretKey` | Chave secreta do Flask (gerar com `openssl rand -hex 32`) | `""` (gerado automaticamente) |
| `persistence.enabled` | Habilitar armazenamento persistente | `true` |
| `persistence.size` | Tamanho do volume | `1Gi` |
| `persistence.storageClassName` | Nome da storage class | `""` (usa default) |
| `ingress.enabled` | Habilitar Ingress | `false` |
| `route.enabled` | Habilitar OpenShift Route | `false` |
| `resources.requests.cpu` | CPU solicitada | `250m` |
| `resources.requests.memory` | Memória solicitada | `256Mi` |
| `resources.limits.cpu` | Limite de CPU | `500m` |
| `resources.limits.memory` | Limite de memória | `512Mi` |

### Exemplo: Kubernetes/Rancher com Ingress

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=velero \
  --set app.timezone="America/Sao_Paulo" \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=seawise.exemplo.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

### Exemplo: OpenShift com Route

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  --set app.veleroNamespace=openshift-adp \
  --set route.enabled=true \
  --set route.tls.enabled=true \
  --set route.tls.termination=edge
```

### Exemplo: Produção com Valores Customizados

Crie um arquivo `production-values.yaml`:

```yaml
image:
  tag: "v1.5.0"
  pullPolicy: IfNotPresent

app:
  veleroNamespace: "velero"
  timezone: "America/Sao_Paulo"
  secretKey: "sua-chave-secreta-de-64-caracteres-hexadecimais"

persistence:
  enabled: true
  storageClassName: "nfs-storage"
  size: 2Gi

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: seawise.producao.com.br
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: seawise-tls
      hosts:
        - seawise.producao.com.br

podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "5000"

nodeSelector:
  node-role.kubernetes.io/infra: ""

tolerations:
  - key: "node-role.kubernetes.io/infra"
    operator: "Exists"
    effect: "NoSchedule"
```

Instalar com:

```bash
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --create-namespace \
  -f production-values.yaml
```

## 🔄 Atualização

```bash
helm upgrade seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  -f production-values.yaml
```

## 🗑️ Desinstalação

```bash
# Desinstalar o chart
helm uninstall seawise-dashboard -n seawise-app

# Remover PVC (opcional - cuidado!)
kubectl delete pvc -n seawise-app seawise-dashboard-pvc

# Remover namespace
kubectl delete namespace seawise-app
```

## 📊 Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                     Seawise Dashboard                           │
│                      (Flask App)                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Web UI        │  │  REST API       │  │  Auth System    │ │
│  │  (Jinja+Tailwind)│  │  (Flask)       │  │  (Session)      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────┤
│  │              Kubernetes Python Client                       │
│  │       (velero.io/v1, oadp.openshift.io/v1alpha1)           │
│  └─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  SQLite DB      │  │  Cluster        │  │  Velero Helper  │ │
│  │  (Users/Settings)│  │  Detector      │  │  (Annotations)  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Velero/OADP    │  │  Node Agent     │  │  Backup Storage │ │
│  │  (Controller)   │  │  (DaemonSet)    │  │  Location (BSL) │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│           ↓                    ↓                     ↓          │
│  ┌─────────────────────────────────────────────────────────────┤
│  │              AWS S3 / Azure Blob / GCP Storage              │
│  └─────────────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────────┘
```

## 🔒 Permissões RBAC

O chart cria automaticamente:

- **ServiceAccount**: `seawise-dashboard`
- **ClusterRole**: Permissões para:
  - Recursos Velero (`velero.io/*`)
  - Recursos OADP (`oadp.openshift.io/*`)
  - Pods (patch para annotations)
  - Secrets (para cloud credentials)
  - Deployments, StatefulSets, DaemonSets, ReplicaSets (read/patch)
  - Namespaces, Nodes, Events (read-only)
  - CRDs (read-only)
  - ClusterVersions (OpenShift - read-only)
- **ClusterRoleBinding**: Vincula ServiceAccount ao ClusterRole
- **Role**: Permissões no namespace do Velero para ler deployment
- **RoleBinding**: Vincula ServiceAccount ao Role

## 📖 Documentação Completa

- **[INSTALL.md](INSTALL.md)**: Guia completo de instalação com troubleshooting
- **[docs/instalacao_velero_completa.md](../../docs/instalacao_velero_completa.md)**: Como instalar e configurar Velero/OADP

## 🧪 Desenvolvimento

### Testar Localmente

```bash
# Validar sintaxe do chart
helm lint ./seawise-dashboard

# Renderizar templates sem instalar (dry-run)
helm template seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --debug

# Instalar em modo dry-run
helm install seawise-dashboard ./seawise-dashboard \
  --namespace seawise-app \
  --dry-run --debug
```

### Empacotar o Chart

```bash
# Criar pacote .tgz
helm package ./seawise-dashboard

# Resultado: seawise-dashboard-1.5.0.tgz
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Faça fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Apache License 2.0

## 🆘 Suporte

- **Issues**: https://github.com/shwcloudapp/seawise-backup/issues
- **Documentação**: https://github.com/shwcloudapp/seawise-backup/tree/main/docs

## 🙏 Agradecimentos

- [Velero](https://velero.io/) - Ferramenta de backup para Kubernetes
- [OADP](https://docs.openshift.com/container-platform/latest/backup_and_restore/index.html) - OpenShift API for Data Protection
- [Flask](https://flask.palletsprojects.com/) - Web framework Python
- [TailwindCSS](https://tailwindcss.com/) - Framework CSS

---

**Desenvolvido com ❤️ pela equipe Seawise**
