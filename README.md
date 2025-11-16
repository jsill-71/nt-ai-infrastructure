# NT-AI Infrastructure

**Multi-region infrastructure as code for NT-AI-Engine ecosystem**

Terraform + Kubernetes + Chaos Mesh for enterprise-grade reliability.

## What This Is

Infrastructure for:
- **Multi-Region Deployment**: East US (primary) + West US (secondary)
- **Chaos Engineering**: Automated resilience testing
- **Monitoring**: Grafana + Prometheus + OpenTelemetry
- **GitOps**: Infrastructure changes via Git workflow

## Components

```
nt-ai-infrastructure/
├── terraform/
│   ├── azure/
│   │   ├── multi-region/     # East + West US
│   │   ├── networking/       # Traffic Manager, VNets
│   │   ├── databases/        # Cosmos DB, PostgreSQL, Redis
│   │   └── compute/          # Container Apps, AKS
│   └── modules/              # Reusable Terraform modules
├── kubernetes/
│   ├── base/                 # Base manifests
│   ├── overlays/
│   │   ├── staging/
│   │   └── production/
│   └── chaos-experiments/    # Chaos Mesh experiments
├── monitoring/
│   ├── grafana/              # Dashboards
│   ├── prometheus/           # Alerts and rules
│   └── opentelemetry/        # Tracing configs
└── scripts/
    ├── deploy-staging.sh
    ├── deploy-production.sh
    └── failover-test.sh
```

## Quick Start

```bash
# Deploy to Azure (staging)
cd terraform/azure
terraform init
terraform plan -var-file=staging.tfvars
terraform apply

# Deploy to Kubernetes
cd kubernetes
kubectl apply -k overlays/staging/

# Run chaos experiment
cd chaos-experiments
kubectl apply -f pod-failure-experiment.yaml
```

## Multi-Region Architecture

**Primary Region**: East US
- All services deployed
- Serves 100% of traffic normally
- Auto-scaling (1-10 replicas)

**Secondary Region**: West US
- Identical deployment (standby)
- Azure Traffic Manager failover
- Takes over if East US fails (<60 sec)

**Failover**: Automatic via Azure Traffic Manager
- Health probes every 10 seconds
- Failover threshold: 2 consecutive failures
- DNS TTL: 60 seconds
- **RTO**: <5 minutes, **RPO**: <1 minute

## Chaos Engineering

**Daily** (Staging):
- Pod failure experiments
- Network latency injection
- Database throttling

**Weekly** (Production):
- Controlled chaos windows
- Limited blast radius (10% of pods)
- Automatic rollback if SLO violated

**Monthly**:
- GameDays (team exercises)
- Full region failover test
- Disaster recovery validation

## Status

**Version**: 0.1.0 (Week 1 pilot)
**Created**: November 16, 2025
**Implementation**: Phase 3 (Multi-Region + Chaos)
**Timeline**: Weeks 11-16 of Phase 3
**Budget**: $18K (infrastructure)

See [Phase 3 Execution Plan](https://github.com/jsill-71/NT-AI-Engine/blob/main/PHASE3_DETAILED_EXECUTION_PLAN.md) for deployment schedule.
