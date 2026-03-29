# Day 1 – Solutions & Recovery Approach

## ✅ Recover kube-apiserver

- Inspect static pod manifest.
- Validate certificates.
- Check container logs:

```bash
kubectl logs <kube-apiserver-pod> -n kube-system
```

## OR
```bash
docker logs <container-id>
```

## ✅ Recover etcd

Restore from snapshot.
Validate data directory.
Restart API server if needed.

## ✅ Fix Static Pod Manifest Issues

Validate YAML syntax.
Check file permissions.
Inspect kubelet logs.
Confirm correct image version.


## ✅ Production Best Practices
Regular etcd backups.
Monitor control plane health.
Enable logging & alerting.
Test disaster recovery periodically.