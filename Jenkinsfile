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
                    echo "Waiting for Inspector v2 to register image (max 5 minutes)..."
                    SCAN_STATUS=""
                    for i in $(seq 1 30); do
                        SCAN_STATUS=$(aws inspector2 list-coverage \
                            --filter-criteria "{\"ecrImageTags\":[{\"comparison\":\"EQUALS\",\"value\":\"$IMAGE_TAG\"}],\"ecrRepositoryName\":[{\"comparison\":\"EQUALS\",\"value\":\"$ECR_REPO_NAME\"}]}" \
                            --region "$AWS_REGION" \
                            --query 'coveredResources[0].scanStatus.status' \
                            --output text 2>/dev/null || echo "")
                        echo "Attempt $i/30 — Inspector status: ${SCAN_STATUS:-not registered}"
                        [ "$SCAN_STATUS" = "ACTIVE" ] && break
                        sleep 10
                    done

                    if [ "$SCAN_STATUS" != "ACTIVE" ]; then
                        echo "ERROR: Inspector v2 did not activate scan within 5 minutes."
                        exit 1
                    fi

                    echo "Checking for HIGH and CRITICAL CVEs..."
                    FAIL=0
                    for SEVERITY in HIGH CRITICAL; do
                        COUNT=$(aws inspector2 list-findings \
                            --filter-criteria "{\"ecrImageTags\":[{\"comparison\":\"EQUALS\",\"value\":\"$IMAGE_TAG\"}],\"ecrRepositoryName\":[{\"comparison\":\"EQUALS\",\"value\":\"$ECR_REPO_NAME\"}],\"severity\":[{\"comparison\":\"EQUALS\",\"value\":\"$SEVERITY\"}]}" \
                            --region "$AWS_REGION" \
                            --max-results 1 \
                            --query 'length(findings)' \
                            --output text 2>/dev/null || echo "0")
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
