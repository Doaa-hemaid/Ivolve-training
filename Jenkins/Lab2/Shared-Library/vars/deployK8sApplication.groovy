def call(String namespace, String dockerImage, String k8sCredentials, String minikubeIp) {
    withCredentials([string(credentialsId: k8sCredentials, variable: 'api_token')]) {
        // Define the common kubectl command prefix
        def kubectlCommand = "kubectl --token $api_token --server https://${minikubeIp}:8443 --insecure-skip-tls-verify=true --validate=false"

        sh """
            ${kubectlCommand} apply -f myapp.yaml
            ${kubectlCommand} get deployments -n ${namespace}
            ${kubectlCommand} get services -n ${namespace}
            echo "Verifying service availability..."
            def serviceOutput = sh(script: """
                ${kubectlCommand} --namespace=${namespace} get svc my-app -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
            """, returnStdout: true).trim()

            if (serviceOutput) {
                echo "Service is available at LoadBalancer IP: ${serviceOutput}"
            } else {
                error("Service LoadBalancer IP not assigned. Please verify the service configuration.")
            }
        """
    }
}
