# Quick Start (Local Deployment)

The Helm chart includes everything needed: PostgreSQL, Redis, MinIO. Everything is deployed with a single command:

```bash
cd deploy

# Install/upgrade release
helm upgrade --install climbing_gym_model ./backend-chart \
  --namespace climbing_gym_model \
  --create-namespace

# Check pod status
kubectl get pods -n climbing_gym_model
```

After startup, you'll need to manually run migrations:

```bash
kubectl exec -n climbing_gym_model deployment/climbing_gym_model-climbing_gym_model-backend -- bin/rails db:migrate # or db:migrate:reset for the first time
```

## Components

The chart deploys:
- **Rails application** - main backend
- **PostgreSQL** - database
- **Redis** - for OTP and caching
- **MinIO** - S3-compatible storage for files

## Application Access

After installation, the application is available at:

**On Linux (k3s):**
- Application: http://localhost
- MinIO console: http://localhost/minio (login: minio / password: minio123)

**On macOS (Docker Desktop):**
- Application: http://localhost
- MinIO console: http://localhost/minio (login: minio / password: minio123)

**Note:** If the application doesn't open, check that Traefik got the localhost address:
```bash
kubectl get svc traefik -n traefik
# Should show EXTERNAL-IP: localhost
```

## Checking Logs

```bash
kubectl logs -n climbing_gym_model deployment/climbing_gym_model-climbing_gym_model-backend
```

## Scaling

To run multiple application instances:

```bash
helm upgrade climbing_gym_model ./backend-chart --set replicaCount=3
```

MinIO ensures correct Active Storage operation with multiple pods.
