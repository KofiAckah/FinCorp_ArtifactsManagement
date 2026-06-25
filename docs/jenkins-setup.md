# Jenkins Setup Guide

This guide covers everything to do manually in the Jenkins UI after `terraform apply` provisions the EC2 instance.

---

## Prerequisites

- Docker buildx plugin must be installed on the Jenkins server:
  ```bash
  sudo apt-get install -y docker-buildx-plugin
  ```



- Jenkins EC2 is running (from `terraform/up.sh` or `terraform apply`)
- Wait ~5 minutes after instance creation for `user_data.sh` to finish
- Get the Jenkins URL from terraform outputs:
  ```bash
  cd terraform/environments/primary
  terraform output jenkins_url
  ```

---

## 1. Unlock Jenkins

1. SSH into the Jenkins server and get the initial admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
2. Open `http://<jenkins-ip>:8080` in your browser
3. Paste the password into the **Administrator password** field and click **Continue**

> **Screenshot:** Take a screenshot of the Jenkins unlock screen with the URL visible in the browser.

---

## 2. Install Suggested Plugins

1. Click **Install suggested plugins**
2. Wait for all plugins to install (~3 minutes)

> **Screenshot:** Take a screenshot of the plugin installation progress screen.

---

## 3. Create Admin User

Fill in the form:
- **Username:** your chosen username
- **Password:** a secure password
- **Full name:** your name
- **Email:** your email

Click **Save and Continue** → **Save and Finish** → **Start using Jenkins**

---

## 4. Install Docker Pipeline Plugin

1. Go to **Manage Jenkins** → **Plugins** → **Available plugins**
2. Search for `Docker Pipeline`
3. Tick the checkbox → click **Install**
4. Wait for the install to complete (no restart required)

> **Screenshot:** Take a screenshot of the Docker Pipeline plugin installed successfully.

---

## 5. Create the Pipeline Job

1. From the Jenkins dashboard click **New Item**
2. Enter name: `fincorp-pipeline`
3. Select **Pipeline** → click **OK**
4. Scroll down to the **Pipeline** section:
   - **Definition:** `Pipeline script from SCM`
   - **SCM:** `Git`
   - **Repository URL:** `https://github.com/KofiAckah/FinCorp.git`
   - **Branch Specifier:** `*/main`
   - **Script Path:** `Jenkinsfile`
5. Click **Save**

> **Screenshot:** Take a screenshot of the pipeline configuration page before saving.

---

## 6. Screenshots to Take Before Running the Build

Take these screenshots **before** clicking Build Now — they show the setup is complete:

| # | What to screenshot |
|---|---|
| 1 | Jenkins dashboard (shows `fincorp-pipeline` job created) |
| 2 | Pipeline configuration page (SCM set to Git, Jenkinsfile path) |
| 3 | ECR repository in AWS console (tag immutability = Enabled, scan on push = Enabled) |
| 4 | CodeArtifact console — domain `fincorp` with `fincorp-main` repo and `npm-store` upstream |
| 5 | AWS Backup console — backup plan with cross-region copy rule to `eu-central-1` |
| 6 | RDS console — `fincorp-primary` instance running in `eu-west-1` |

---

## 7. Run the Pipeline

1. From the `fincorp-pipeline` job page, click **Build Now**
2. Click the build number (e.g. `#1`) → **Console Output** to watch live
3. The pipeline will:
   - Authenticate with AWS CodeArtifact and configure npm
   - Build the Docker image (npm packages pulled through CodeArtifact)
   - Push the image to ECR with tag `<build-number>-<git-sha>`
   - Poll ECR scan results and **fail the build** if HIGH or CRITICAL CVEs are found

> **Screenshot:** Take a screenshot of the completed pipeline with all stages green (or a failed CVE gate if vulnerabilities are found — both are valid outcomes for the demo).

---

## Rebuilding from Scratch

If you tear down and recreate all resources:

```bash
# Destroy everything
bash terraform/down.sh

# Recreate everything
bash terraform/up.sh

# Rebuild just the Jenkins instance (leaves RDS/ECR/CodeArtifact untouched)
cd terraform/environments/primary
terraform apply -replace="module.jenkins.aws_instance.jenkins"
```

After rebuild, repeat steps 1–7 above. All AWS resources (ECR, CodeArtifact, RDS, Backup) are recreated automatically — only the Jenkins UI configuration is manual.
