properties([pipelineTriggers([
  [$class: 'GitHubPushTrigger'], pollSCM('H/3 * * * *')
])])

def sendMail(userMail){
    def logContent = Jenkins.getInstance()
    .getItemByFullName(env.JOB_NAME)
    .getBuildByNumber(Integer.parseInt(env.BUILD_NUMBER))
    .logFile.text
    // copy the log in the job's own workspace
    writeFile file: "buildlog.txt", text: logContent
    
    emailext (
        attachmentsPattern: 'buildlog.txt',
        subject: "FINISH: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
        body: """
          STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}] ${env.BUILD_URL}':
          Check console output at "${env.JOB_NAME} [${env.BUILD_NUMBER}]"
          """,
        to: userMail
    )
}

node {
    def committerEmail = sh (
        script: 'git --no-pager show -s --format=\'%ae\'',
        returnStdout: true
    ).trim();

    def committerName = sh (
        script: 'git --no-pager show -s --format=\'%an\'',
        returnStdout: true
    ).trim();

  // def committerEmail = "onur.polat@mobven.com";
  // def committerName = "Onur POLAT";
    def ts = "";
    def PROJECT_ICON = "https://www.amchamksv.org/wp-content/uploads/2018/05/bkt.png";
    def WORKSPACE = pwd();
    // Git Configuration
    def REPO_URL = "https://github.com/mobven/OneLink.git";
    // SonarQube Configuration
    def SONAR_PROJECT_KEY = "com.mobven.ios.oneLink.sb";
    def SONAR_PROJECT_NAME = "OneLink";
    def SONAR_KEY = "0c15b3e6e94f81d28f88bf2a50b446cdb1c8fe83";
    def SONAR_URL = "http://farm.mobven.com:9000";
    def COVERAGE_PATH = "sonarqube-generic-coverage.xml";
    def SLACK_DATA = "'${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'";
    def SLACK_SH = "/Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh";

    stage('Preparation') {
        try {
            // Get code from a GitHub repository
            git branch: env.BRANCH_NAME, credentialsId: 'SS', url: REPO_URL
            ts = sh(script: "bash ${SLACK_SH} '${env.STAGE_NAME}' 0 ${SLACK_DATA}", returnStdout: true )
            sh "rm -rf sonar-reports"
            sh "rm -rf reports/*"
            sh "cp /Users/mobvenserver/sonar-project.properties ."
        } catch (e) {
            sh "bash ${SLACK_SH} 'ErrorStage' '${ts}' ${SLACK_DATA}"
            sendMail(committerEmail);
            currentBuild.result = 'ABORTED'
            error('Aborted due to a encountered error.')
        }
    }

    stage ('Test') {
        try {
            sh "bash ${SLACK_SH} '${env.STAGE_NAME}' '${ts}' ${SLACK_DATA}"
            sh "xcodebuild -scheme MBOneLink -sdk iphonesimulator -derivedDataPath Build/ -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.4' test -enableCodeCoverage YES"
        } catch (e) {
            sh "bash ${SLACK_SH} 'ErrorStage' '${ts}' ${SLACK_DATA}"
            sendMail(committerEmail);
            currentBuild.result = 'ABORTED'
            error('Aborted due to a encountered error.')
        }
    }

    stage ('Coverage Generation') {
        try {
            sh "bash ${SLACK_SH} '${env.STAGE_NAME}' '${ts}' ${SLACK_DATA}"
            sh "bash xccov-to-sonarqube-generic.sh Build/Logs/Test/*.xcresult/ > sonarqube-generic-coverage.xml"
        } catch (e) {
            sh "bash ${SLACK_SH} 'ErrorStage' '${ts}' ${SLACK_DATA}"
            sendMail(committerEmail);
            currentBuild.result = 'ABORTED'
            error('Aborted due to a encountered error.')
        }
    }

    stage ('Quality Check') {
        try {
            sh "bash ${SLACK_SH} '${env.STAGE_NAME}' '${ts}' ${SLACK_DATA}"
            
            withSonarQubeEnv('LocalSonarQube'){ // SonarQube taskId is automatically attached to the pipeline context
                sh "sonar-scanner -Dsonar.host.url=${SONAR_URL} -Dsonar.login=${SONAR_KEY} -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.coverageReportPaths=${COVERAGE_PATH} -Dsonar.cfamily.build-wrapper-output.bypass=true"
            }
        } catch (e) {
            sh "bash ${SLACK_SH} 'ErrorStage' '${ts}' ${SLACK_DATA}"
            sendMail(committerEmail);
            currentBuild.result = 'ABORTED'
            error('Aborted due to a encountered error.')
        }
    }

    stage('Quality Gate'){
        sh "bash ${SLACK_SH} '${env.STAGE_NAME}' '${ts}' ${SLACK_DATA}"
        sleep(10) // Just in case something goes wrong, pipeline will be killed after a timeout
        def qg = waitForQualityGate()
        waitForQualityGate abortPipline: true // Reuse taskId previously collected by withSonarQubeEnv

        if (qg.status != 'OK') {
          sh "bash ${SLACK_SH} 'ErrorSQ2' '${ts}' ${SLACK_DATA}"
          error "Pipeline aborted due to quality gate failure: ${qg.status}"
        }
    }

    stage ('Jira') {
        def commitMessage =  sh ( 
            script: 'git log --format=format:%s -1', // find commitMessage
            returnStdout: true
        ).trim()
        
        def regex = /[A-Z]{2,3}-\d{1,4}/
        def commitMessageFormat = (commitMessage =~ regex).findAll() //convert format
        
        String [] ary;
        ary = commitMessageFormat //convert array
      
      if (commitMessageFormat.size() == 0){
        sh "bash ${SLACK_SH} 'Success' '${ts}' ${SLACK_DATA}"
      } else {
        
        for (String values : ary) {
            sh "bash /Users/mobvenserver/.jenkins/workspace/Jira-Updater.sh '${values}'"
        }
        
        sh "bash ${SLACK_SH} 'Success' '${ts}' ${SLACK_DATA}"
      }
    }

}
