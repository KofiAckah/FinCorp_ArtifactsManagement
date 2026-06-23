# The "Immutable and Indestructible" pipeline - Fincorp

**Scenario:** FinCorp requires a highly secure, auditable software supply chain. They also need a disaster recovery plan that ensures their critical database can be restored in a different region within 30 minutes.

---

## Objectives

- Implement a secure CI/CD pipeline that produces immutable artifacts
- Demonstrate a Cross-Region Disaster Recovery (DR) failover

---

## Instructions

**1. Artifact pipeline**

- Set up AWS CodeArtifact as an upstream proxy for npm/pip
- Create a pipeline (CodePipeline/Jenkins/GitHub Actions) that builds the app, pushes the Docker image to Amazon ECR with "Image Scanning" enabled and "Tag Immutability" turned on
- Constraint: The build must fail if High/Critical vulnerabilities are found

**2. Disaster recovery (DR)**

- Deploy an RDS database in us-east-1
- Configure AWS Backup to create daily snapshots and copy them to us-west-2 (Cross-Region Copy)
- Simulation: Simulate a "Region Failure" by deleting the primary DB
- Recovery: Restore the database in us-west-2 from the copied backup

---

> Make sure to document everything in this project. Submission includes documentation and a live walkthrough.
