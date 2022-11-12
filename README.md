# STACK the Codes 2022

## Problem Statement:
mTLS is a much needed baseline for Zero-Trust as a whole. However, its PKI setup requires heavy operational
investment and resources from agencies which also  includes the management of the key lifecycle from provisioning to renewal to revocation.
If any of the stages are not handled timely, the impact is  rippled to the web services and may bring down the
business in worst case.

The emergence of SPIFFE issuing X.509 SVID also means  that whole setup need some form of “transformation” into
mesh network and sidecar driven setup (towards a K8  architecture). Challenge is whether there is an optimal (and
yet secure) translation from existing PKI to SPIFFE or an  alternative to achieve a reasonable identity-based attestation level.

## Submission:
- [Demo video]()
- Overview: we demo a full transition from legacy PKI to mTLS with SPIFFE
  - Stage 0: Microservices in Docker with TLS from a Certificate Authority
  - Stage 1: Migrating to Kubernetes 
  - Stage 2: Transition into SPIFFE for mTLS
- Following the walk through for Stage 0 and 1 in [./pki/README.md](./pki/README.md), and for Stage 2 in [./k8s/README.md](./k8s/README.md)
- Optimization consideration: 
  - Using Ansible and Shell scripting to automate transition
- Security consideration:
  - No hard-coding of password required during the whole process
  - Making use of Kubernetes secret for TLS
  - Serve Tornjak GUI for SPIRE on HTTPS

## Acknowledgment:
- Tran Nguyen Bao Long [@TNBL265](https://github.com/TNBL265)
- Ivan Feng [@IvanFengJK](https://github.com/IvanFengJK)
- Ryan Toh [@Rye123](https://github.com/Rye123)