# Kubernetes Node Security Hardening

This Ansible project implements security best practices for Kubernetes nodes based on industry standards. It helps secure the Linux hosts running Kubernetes components without disrupting running services.

## Features

- **SSH Hardening**: Secures SSH configuration, disables root login, enforces key-based authentication
- **Admin User Setup**: Creates a dedicated admin user with appropriate permissions
- **Firewall Configuration**: Sets up UFW with appropriate rules for Kubernetes services
- **Kernel Hardening**: Applies secure kernel parameters suitable for Kubernetes
- **Audit Logging**: Configures auditd for system event logging
- **Fail2ban**: Protects against brute-force attacks
- **Container Runtime Security**: Secures containerd with appropriate settings

## Requirements

- Ansible 2.9+ (use the provided Docker wrapper if you don't have Ansible installed)
- SSH access to the Kubernetes nodes
- Root or sudo access on the target nodes

## Usage

### Using the Docker Wrapper (Recommended)

The easiest way to run this playbook is using the provided Docker wrapper script:

```bash
./run-with-docker.sh --private-key=~/.ssh/id_ed25519 --user=root
```

### Manual Execution

If you have Ansible installed locally, you can run the playbook directly:

```bash
ansible-playbook k8s-security.yml -i inventory/hosts.ini --private-key=~/.ssh/id_ed25519 --user=root
```

### Options

- Run against specific nodes or groups:
  ```bash
  ./run-with-docker.sh --limit=kube-node-1 --private-key=~/.ssh/id_ed25519 --user=root
  ```

- Run specific role tags only:
  ```bash
  ./run-with-docker.sh --tags=ssh_hardening,firewall --private-key=~/.ssh/id_ed25519 --user=root
  ```

- Test mode (dry run):
  ```bash
  ./run-with-docker.sh --check --private-key=~/.ssh/id_ed25519 --user=root
  ```

## Important Notes

1. Always test in `--check` mode before applying changes to production systems
2. Ensure you have backup access methods in case SSH configuration changes lock you out
3. Review the variables in `vars/main.yml` to customize the security settings for your environment
4. Make sure your kubernetes services and networking remain functional after applying security hardening

## License

MIT

## References

- [Kubernetes Security Checklist](https://kubernetes.io/docs/concepts/security/security-checklist/)
- [NSA & CISA Kubernetes Hardening Guide](https://www.nsa.gov/portals/75/documents/what-we-do/cybersecurity/professional-resources/ctr-kubernetes-hardening-guidance.pdf)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes/) 