def call(String imageName, String credentialsId = 'docker-hub-log') {
    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
        sh """
            docker build -t ${imageName} .
            echo \$PASSWORD | docker login --username \$USER --password-stdin
            docker push ${imageName}
        """
    }
}
