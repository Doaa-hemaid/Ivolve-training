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
                withCredentials([usernamePassword(credentialsId: 'docker-hub-log',
                                  usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) 
                {
                    sh """
                        docker build -t doaahemaid01/my-app:1.0 .
                        echo $PASSWORD | docker login --username $USER --password-stdin
                        docker push doaahemaid01/my-app:1.0 
                    """
                }
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
                sh """
                    oc login $OPENSHIFT_SERVER --token=$OPENSHIFT_TOKEN --insecure-skip-tls-verify
                    oc project $OPENSHIFT_PROJECT
                    #Check if the deployment exists
                    if oc get deployment.apps/my-app; then
                       echo "Deployment my-app already exists."
                    else
                       oc create deployment my-app --image=doaahemaid01/my-app:1.0
                    fi
                    #oc create deployment my-app --image=doaahemaid01/my-app:1.0
                    
                    oc rollout status deployment.apps/my-app
                """
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
