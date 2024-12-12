@Library('shared-library@main') _
pipeline {
    agent any
    environment { 
        OPENSHIFT_TOKEN = credentials('open-shift-token	') 
        OPENSHIFT_SERVER = 'https://api.ocp-training.ivolve-test.com:6443' 
        OPENSHIFT_PROJECT = 'doaahemaid' } 
    stages {
        stage('Build Image') {
            steps {
                echo 'Building...'
                DockerBuildPush('doaahemaid01/my-app:1.0')
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'
                // Add your test steps here
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
               echo 'Deploying to OpenShift...'
            DeployingOpenShift('my-app', 'doaahemaid01/my-app:1.0')
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
