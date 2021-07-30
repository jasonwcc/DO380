pipeline {
  triggers {
    //FIX-ME
  }
  options {
    disableConcurrentBuilds()
  }
  agent {
    node {
      label 'nodejs'
    }
  }
  stages {
    stage ('Validate configuration resources') {
      steps {
        sh 'oc apply --dry-run --validate -k samples'
        sh 'oc delete --dry-run -f delete'
      }
    }
    stage ('Apply resources') {
      when {
        //FIX-ME
      }
      steps {
        //FIX-ME
        // ignore delete errors caused by templates deleted by previous runs
        sh 'oc delete -f delete --wait || true'
      }
    }
    stage ('Verify deleted templates') {
      when {
        //FIX-ME
      }
      steps {
        sh '! oc get templates -n openshift | grep -q rails'
      }
    }
  }
}
