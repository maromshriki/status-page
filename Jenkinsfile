pipeline {
    agent {
        docker {
            image 'maven:3.9.5-eclipse-temurin-17'   // Example Docker image, replace if needed
            args '-v /root/.m2:/root/.m2'           // Cache Maven dependencies (optional)
        }
    }

    environment {
        APP_NAME = "my-application"
        DOCKER_REGISTRY = "registry.example.com"
        DEPLOY_ENV = "${BRANCH_NAME == 'main' ? 'production' : 'development'}"
    }

    stages {
        // Common Stage (applies to all branches)
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Development branch stages
        stage('Dev Build') {
            when { branch 'dev' }
            steps {
                sh "mvn clean compile"
            }
        }

        stage('Dev Test') {
            when { branch 'dev' }
            steps {
                sh "mvn test"
            }
        }

        stage('Dev Package') {
            when { branch 'dev' }
            steps {
                sh "mvn package -DskipTests"
            }
        }

        stage('Dev Deploy') {
            when { branch 'dev' }
            steps {
                echo "Deploying ${APP_NAME} to ${DEPLOY_ENV}"
            }
        }

        // Main branch stages
        stage('Main Build') {
            when { branch 'main' }
            steps {
                sh "mvn clean compile"
            }
        }

        stage('Main Test') {
            when { branch 'main' }
            steps {
                sh "mvn test"
            }
        }

        stage('Code Quality') {
            when { branch 'main' }
            steps {
                sh "mvn verify sonar:sonar"
            }
        }

        stage('Security Scan') {
            when { branch 'main' }
            steps {
                sh "echo Running security scan..."
            }
        }

        stage('Main Package') {
            when { branch 'main' }
            steps {
                sh "mvn package -DskipTests"
            }
        }

        stage('Docker Build & Push') {
            when { branch 'main' }
            steps {
                sh """
                    docker build -t ${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER} .
                    docker push ${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}
                """
            }
        }

        stage('Main Deploy') {
            when { branch 'main' }
            steps {
                echo "Deploying ${APP_NAME} to ${DEPLOY_ENV}"
            }
        }
    }
}
