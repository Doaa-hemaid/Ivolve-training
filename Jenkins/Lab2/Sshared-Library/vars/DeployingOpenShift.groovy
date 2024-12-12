def call(String appName, String imageName) { 
    sh """
        oc login ${env.OPENSHIFT_SERVER} --token=${env.OPENSHIFT_TOKEN} --insecure-skip-tls-verify
        oc project ${env.OPENSHIFT_PROJECT}
        
        # Create the deployment
        oc create deployment ${appName} --image=${imageName} 

        # Start the service for the deployment
        oc expose deployment/${appName} --port=80

        # Get the deployment details
        oc get deployment.apps/${appName}

        # Get the service details
        oc get svc ${appName}
    """
}
