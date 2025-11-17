# PostgreSQL High Availability - Zone Redundant
# Phase 3 Week 2 Task 2.3

resource "azurerm_postgresql_flexible_server" "nt_ai_main" {
  name                = "nt-ai-postgresql"
  resource_group_name = azurerm_resource_group.nt_ai.name
  location            = "East US"

  sku_name   = "GP_Standard_D2s_v3"  # General Purpose, 2 vCores
  storage_mb = 32768                  # 32 GB
  version    = "16"

  # High Availability
  zone                          = "1"
  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  # Backup
  backup_retention_days        = 30
  geo_redundant_backup_enabled = true

  # Authentication
  administrator_login    = "ntaiadmin"
  administrator_password = var.postgresql_password  # From Key Vault

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "NT-AI-Platform"
  }
}

# Connection pooler (PgBouncer)
resource "azurerm_container_app" "pgbouncer" {
  name                         = "nt-ai-pgbouncer"
  container_app_environment_id = azurerm_container_app_environment.nt_ai.id
  resource_group_name          = azurerm_resource_group.nt_ai.name
  revision_mode                = "Single"

  template {
    container {
      name   = "pgbouncer"
      image  = "edoburu/pgbouncer:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "DATABASE_URL"
        value = "postgres://${azurerm_postgresql_flexible_server.nt_ai_main.administrator_login}@${azurerm_postgresql_flexible_server.nt_ai_main.fqdn}:5432/postgres"
      }

      env {
        name        = "DB_PASSWORD"
        secret_name = "postgresql-password"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 5432
  }

  secret {
    name  = "postgresql-password"
    value = var.postgresql_password
  }
}

output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.nt_ai_main.fqdn
}

output "pgbouncer_url" {
  value = "postgresql://${azurerm_postgresql_flexible_server.nt_ai_main.administrator_login}@${azurerm_container_app.pgbouncer.ingress[0].fqdn}:5432/postgres"
}
