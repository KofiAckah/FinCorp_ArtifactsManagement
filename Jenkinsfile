pipeline {
    agent any

    environment {
        AWS_REGION    = 'eu-west-1'
        ECR_REGISTRY  = '412381768295.dkr.ecr.eu-west-1.amazonaws.com'
        ECR_REPO_NAME = 'fincorp/finance-tracker'
        ECR_REPO      = "${ECR_REGISTRY}/${ECR_REPO_NAME}"
        CA_DOMAIN     = 'fincorp'
        CA_OWNER      = '412381768295'
        CA_REPO       = 'fincorp-main'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                    echo "Building image: ${env.ECR_REPO}:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Configure CodeArtifact') {
            steps {
                sh '''
                    CA_TOKEN=$(aws codeartifact get-authorization-token \
                        --domain "$CA_DOMAIN" \
                        --domain-owner "$CA_OWNER" \
                        --query authorizationToken \
                        --output text \
                        --region "$AWS_REGION")

                    CA_URL=$(aws codeartifact get-repository-endpoint \
                        --domain "$CA_DOMAIN" \
                        --domain-owner "$CA_OWNER" \
                        --repository "$CA_REPO" \
                        --format npm \
                        --query repositoryEndpoint \
                        --output text \
                        --region "$AWS_REGION")

                    printf 'registry=%s\n%s:_authToken=%s\n' \
                        "$CA_URL" "${CA_URL#https:}" "$CA_TOKEN" > app/.npmrc

                    echo "npm registry configured: $CA_URL"
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker run --rm \
                        -v "$(pwd)/app/server:/usr/src/app" \
                        -v "$(pwd)/app/.npmrc:/root/.npmrc:ro" \
                        -w /usr/src/app \
                        node:24-alpine \
                        sh -c "npm ci && npm test"
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    docker build \
                        --secret id=npmrc,src=app/.npmrc \
                        -t "$ECR_REPO:$IMAGE_TAG" \
                        app/
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region "$AWS_REGION" | \
                        docker login --username AWS --password-stdin "$ECR_REGISTRY"
                    docker push "$ECR_REPO:$IMAGE_TAG"
                    echo "Pushed: $ECR_REPO:$IMAGE_TAG"
                '''
            }
        }

        stage('CVE Gate') {
            steps {
                sh '''
                    echo "Polling ECR basic scan results for $ECR_REPO_NAME:$IMAGE_TAG (max 5 minutes)..."
                    STATUS="NOT_STARTED"
                    for i in $(seq 1 30); do
                        STATUS=$(aws ecr describe-image-scan-findings \
                            --repository-name "$ECR_REPO_NAME" \
                            --image-id imageTag="$IMAGE_TAG" \
                            --region "$AWS_REGION" \
                            --query 'imageScanStatus.status' \
                            --output text 2>/dev/null || echo "NOT_STARTED")
                        echo "Attempt $i/30 — scan status: $STATUS"
                        [ "$STATUS" = "COMPLETE" ] && break
                        [ "$STATUS" = "FAILED" ]   && { echo "ERROR: ECR image scan failed."; exit 1; }
                        sleep 10
                    done

                    if [ "$STATUS" != "COMPLETE" ]; then
                        echo "ERROR: ECR scan did not complete within 5 minutes (last status: $STATUS)."
                        exit 1
                    fi

                    echo "Checking for HIGH and CRITICAL CVEs..."
                    FAIL=0
                    for SEVERITY in HIGH CRITICAL; do
                        COUNT=$(aws ecr describe-image-scan-findings \
                            --repository-name "$ECR_REPO_NAME" \
                            --image-id imageTag="$IMAGE_TAG" \
                            --region "$AWS_REGION" \
                            --query "imageScanFindings.findingSeverityCounts.$SEVERITY" \
                            --output text 2>/dev/null)
                        if [ "$COUNT" = "None" ] || [ -z "$COUNT" ]; then
                            COUNT=0
                        fi
                        echo "$SEVERITY: $COUNT"
                        [ "$COUNT" -gt 0 ] && FAIL=1
                    done

                    if [ "$FAIL" -eq 1 ]; then
                        echo "BUILD FAILED: HIGH or CRITICAL CVEs detected. Fix vulnerabilities before merging."
                        exit 1
                    fi

                    echo "CVE gate PASSED — no HIGH or CRITICAL vulnerabilities found."
                '''
            }
        }
    }

    post {
        always {
            sh 'rm -f app/.npmrc || true'
        }
        success {
            echo "Pipeline complete. Image: ${env.ECR_REPO}:${env.IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed at stage: ${env.STAGE_NAME}. Check logs above."
        }
    }
}
