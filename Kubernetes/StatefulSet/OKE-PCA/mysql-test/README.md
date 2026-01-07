# MySQL Test Deployment on OKE

This directory contains Kubernetes manifests for deploying MySQL 8.0 for testing purposes on Oracle Kubernetes Engine (OKE) with OCI Block Volume storage.

## Architecture

- **Storage Class**: `oci-bv` (Standard OCI Block Volume)
- **Storage Size**: 20Gi
- **MySQL Version**: 8.0
- **Deployment Type**: StatefulSet (single replica)
- **Namespace**: mysql-test

## Files

- `00-namespace.yaml` - Creates the mysql-test namespace
- `01-secret.yaml` - MySQL credentials (root, user, and database)
- `02-statefulset.yaml` - MySQL StatefulSet with persistent storage
- `03-service.yaml` - Headless and client services for MySQL

## Storage Configuration

The deployment uses **oci-bv** storage class:
- **Type**: Standard OCI Block Volume
- **Performance**: ~60 IOPS/GB (sufficient for testing)
- **Cost**: Cost-optimized for dev/test
- **Size**: 20Gi (can be expanded if needed)
- **Reclaim Policy**: Delete (volume deleted when PVC is deleted)
- **Binding Mode**: WaitForFirstConsumer (volume created in same AD as pod)

## Deployment Steps

### 1. Deploy all resources

```bash
kubectl apply -f k8s/mysql-test/
```

Or deploy in order:

```bash
kubectl apply -f k8s/mysql-test/00-namespace.yaml
kubectl apply -f k8s/mysql-test/01-secret.yaml
kubectl apply -f k8s/mysql-test/02-statefulset.yaml
kubectl apply -f k8s/mysql-test/03-service.yaml
```

### 2. Verify deployment

```bash
# Check namespace
kubectl get namespace mysql-test

# Check all resources
kubectl get all -n mysql-test

# Check PVC (Persistent Volume Claim)
kubectl get pvc -n mysql-test

# Check PV (Persistent Volume)
kubectl get pv

# Check pod status and logs
kubectl get pods -n mysql-test
kubectl logs -n mysql-test mysql-0

# Wait for pod to be ready
kubectl wait --for=condition=ready pod/mysql-0 -n mysql-test --timeout=300s
```

### 3. Test MySQL connection

**Using kubectl exec:**

```bash
# Connect to MySQL as root
kubectl exec -it -n mysql-test mysql-0 -- mysql -u root -p
# Password: TestMySQL@123

# Connect to testdb as testuser
kubectl exec -it -n mysql-test mysql-0 -- mysql -u testuser -ptestuser -D testdb
# Password: TestUser@123
```

**Using a test client pod:**

```bash
# Create a MySQL client pod
kubectl run mysql-client --rm -it --image=mysql:8.0 -n mysql-test -- bash

# Inside the client pod, connect to MySQL
mysql -h mysql-client.mysql-test.svc.cluster.local -u testuser -p
# Password: TestUser@123
```

### 4. Run sample queries

```sql
-- Show databases
SHOW DATABASES;

-- Use test database
USE testdb;

-- Create a test table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO users (name, email) VALUES
    ('Test User 1', 'user1@example.com'),
    ('Test User 2', 'user2@example.com');

-- Query data
SELECT * FROM users;

-- Check storage usage
SELECT
    table_schema AS 'Database',
    SUM(data_length + index_length) / 1024 / 1024 AS 'Size (MB)'
FROM information_schema.tables
GROUP BY table_schema;
```

## Storage Operations

### Check storage usage

```bash
# Check PVC details
kubectl describe pvc -n mysql-test mysql-data-mysql-0

# Check actual disk usage inside pod
kubectl exec -n mysql-test mysql-0 -- df -h /var/lib/mysql
```

### Expand storage (if needed)

```bash
# Edit PVC to increase size (e.g., from 20Gi to 50Gi)
kubectl edit pvc mysql-data-mysql-0 -n mysql-test

# Change: storage: 20Gi -> storage: 50Gi
# Save and the volume will be automatically expanded
```

### Backup database

```bash
# Backup to local file
kubectl exec -n mysql-test mysql-0 -- mysqldump -u root -pTestMySQL@123 --all-databases > mysql-backup.sql

# Or create a backup inside the pod
kubectl exec -n mysql-test mysql-0 -- mysqldump -u root -pTestMySQL@123 --all-databases > /var/lib/mysql/backup.sql
```

## Monitoring

### Check MySQL status

```bash
# View logs
kubectl logs -n mysql-test mysql-0 -f

# Check resource usage
kubectl top pod -n mysql-test mysql-0

# Get pod details
kubectl describe pod -n mysql-test mysql-0
```

### Health checks

```bash
# Check liveness probe
kubectl exec -n mysql-test mysql-0 -- mysqladmin ping -h localhost

# Check MySQL status
kubectl exec -n mysql-test mysql-0 -- mysql -u root -pTestMySQL@123 -e "STATUS;"
```

## Cleanup

### Delete MySQL deployment (keeps PVC)

```bash
kubectl delete statefulset mysql -n mysql-test
kubectl delete service mysql mysql-client -n mysql-test
```

### Delete everything including data

```bash
# Warning: This will delete all data!
kubectl delete namespace mysql-test

# PVC and PV will be automatically deleted due to Delete reclaim policy
```

### Manual PVC deletion

```bash
kubectl delete pvc mysql-data-mysql-0 -n mysql-test
```

## Default Credentials

**⚠️ WARNING: These are test credentials only. Change for production!**

- **Root User**:
  - Username: `root`
  - Password: `TestMySQL@123`

- **Application User**:
  - Username: `testuser`
  - Password: `TestUser@123`
  - Database: `testdb`

## Troubleshooting

### Pod not starting

```bash
# Check pod events
kubectl describe pod -n mysql-test mysql-0

# Check PVC status
kubectl describe pvc -n mysql-test mysql-data-mysql-0

# Check logs
kubectl logs -n mysql-test mysql-0
```

### Storage issues

```bash
# Check if storage class exists
kubectl get sc oci-bv

# Check if PV is bound
kubectl get pv

# Check CSI driver
kubectl get pods -n kube-system | grep csi
```

### Connection issues

```bash
# Test DNS resolution
kubectl run -it --rm debug --image=busybox -n mysql-test -- nslookup mysql-client.mysql-test.svc.cluster.local

# Check service endpoints
kubectl get endpoints -n mysql-test mysql-client
```

## Upgrading to Production

To upgrade this deployment for production:

1. Change storage class to `oci-bv-high` in [02-statefulset.yaml](02-statefulset.yaml:58)
2. Increase storage size (e.g., 100Gi or more)
3. Change credentials in [01-secret.yaml](01-secret.yaml) to strong passwords
4. Add resource limits based on workload
5. Enable MySQL replication (increase replicas)
6. Configure backups and monitoring
7. Set up proper RBAC and network policies

## Notes

- This is a **single-instance** deployment suitable for testing only
- For production, consider using MySQL Operator or managed database services
- Storage uses **Delete** reclaim policy - data will be lost if PVC is deleted
- Volume expansion is supported - you can increase size without downtime
- The deployment uses **WaitForFirstConsumer** binding, so the volume is created in the same availability domain as the pod
