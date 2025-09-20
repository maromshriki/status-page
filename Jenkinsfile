pipeline {
  agent any

  environment {
    IMAGE_NAME_WEB = "msdw-mbp_main-web"
    PROD_SERVER = "10.0.12.164"
    PROD_USER = "ec2-user"
    DEV_SERVER = "10.0.2.14"
    DEV_USER = "ubuntu"
    CICD_SERVER = "10.0.1.205"
    CICD_USER = "ec2-user"
    SSH_CREDENTIALS_ID_PROD = 'ssh-ekscontrol'
    SSH_CREDENTIALS_ID_DEV = 'ssh-to-dev-server'
    SSH_EKS_CREDS = 'ssh-ekscontrol'
    APP_NAME = "status-page"
    REMOTE_REGISTRY = "992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web"
    DEPLOY_ENV = "${BRANCH_NAME == 'main' ? 'production' : 'development'}"
    BUILD_TAG = "${BRANCH_NAME == 'main' ? "main-${env.BUILD_NUMBER}" : "pr-${CHANGE_ID}"}"
    SLACK_CHANNEL = '#devops-alerts'
  }

  stages {

    stage('Dev Build') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh '[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0777 ~/.ssh'
          sh "ssh-keyscan -t rsa,dsa $DEV_SERVER >> ~/.ssh/known_hosts"
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page; docker build -t msdw/statuspage-web .'"
        }
      }
    }

    stage('Dev Deploy to Minikube') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page/minikube; kubectl apply -f .'"
        }
      }
    }

    stage('Dev upload to ECR') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh  "ssh $DEV_USER@$DEV_SERVER 'cd /opt/status-page/'"
          sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com'
          sh "docker tag msdw/statuspage-web $REMOTE_REGISTRY:${CHANGE_ID}"
          sh "docker push $REMOTE_REGISTRY:pr-${CHANGE_ID}"
        }
      }
    }


    stage('Deploy to EKS') {
      when { branch 'main' }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_PROD"]) {
          script {
            try {
              sh "ssh-keyscan -t rsa,dsa $PROD_SERVER >> ~/.ssh/known_hosts"
              sh "ssh $PROD_USER@$PROD_SERVER"
              sh """
                kubectl apply -f k8s/
                kubectl set image deployment/status-page status-page=$REMOTE_REGISTRY:latest 
                kubectl rollout status deployment/status-page
              """
            } catch (err) {	
              echo "Deployment failed! Rolling back..."
              sh "kubectl rollout undo deployment/status-page"
              error("Rollback executed due to failure.")
            }
          }
        }
      }
    }
  }

  post {
    failure {
      slackSend(channel: "${SLACK_CHANNEL}", message: "Pipeline failed for ${env.JOB_NAME} #${env.BUILD_NUMBER}")
    }
    success {
      slackSend(channel: "${SLACK_CHANNEL}", message: "Pipeline succeeded for ${env.JOB_NAME} #${env.BUILD_NUMBER}")
    }
  }
}
