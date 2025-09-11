pipeline {
  agent any

  environment {
    IMAGE_NAME_WEB = "satatus-page-web"
    FILE_NAME = "Jenkinsfile"
    PRODUCTION_SERVER = "10.0.1.110"
    PRODUCTION_USER = "ec2-user"
    DEV_SERVER = "10.0.2.14"
    DEV_USER = "ubuntu"
    CICD_SERVER = "10.0.1.205"
    CICD_USER = "ec2-user"
    SSH_CREDENTIALS_ID_PROD = 'ssh-to-prod-server'
    SSH_CREDENTIALS_ID_DEV = 'ssh-to-dev-server'
    APP_NAME = "status-page"
    REMOTE_REGISTRY = "992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web"
    DEPLOY_ENV = "${BRANCH_NAME == 'main' ? 'production' : 'development'}"
  }

  stages {

    stage('Dev Build') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh '[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0777 ~/.ssh'
          sh "ssh-keyscan -t rsa,dsa $DEV_server >> ~/.ssh/known_hosts"
          sh 'docker-compose build'
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page; docker-compose build'"
        }
      }
    }

    stage('Dev deploy to minikube cluster') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page/minikube; kubectl apply -f .'"
        }
      }
    }

    stage('Dev Deploy to ecr with specific tagging') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com'
          sh "docker tag msdw-mbp_pr-$CHANGE_ID-web 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:pr-web-$CHANGE_ID"
          sh 'docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:pr-web-$CHANGE_ID'
        }
      }
    }

    // Main branch stages
    stage('Main Build') {
      when { branch 'main' }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh '[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0777 ~/.ssh'
          sh "ssh-keyscan -t rsa,dsa $DEV_server >> ~/.ssh/known_hosts"
          sh 'docker-compose build'
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/status-page; docker-compose build'"
          }
        }
     }

    stage('Main Test') {
      when { branch 'main' }
      steps {
        sh "echo sometests..."
      }
    }
    
    stage('Docker Build & Push') {
      when { branch 'main' }
      steps {
        sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com'
        sh "docker tag $IMAGE_NAME_WEB 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:latest"
        sh 'docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web:latest'
        }
        
        
        }
      }
  }
}
        
