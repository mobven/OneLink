properties([pipelineTriggers([
  [$class: 'GitHubPushTrigger'], pollSCM('H/3 * * * *')
])])



def sendMail(userMail){


        slackSend color: '#008000', message: "Failed Logs, Sent by Email. Please Check Email Box :email: "

                def logContent = Jenkins.getInstance()
                   .getItemByFullName(env.JOB_NAME)
                    .getBuildByNumber(
                     Integer.parseInt(env.BUILD_NUMBER))
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
          //recipientProviders: [[$class: 'DevelopersRecipientProvider']]
        )
}


node {

  def committerEmail = sh (
        script: 'git --no-pager show -s --format=\'%ae\'',
        returnStdout: true
        ).trim()
  def committerName = sh (
      script: 'git --no-pager show -s --format=\'%an\'',
      returnStdout: true
      ).trim()

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
  def SONAR_URL = "http://192.168.1.240:9000";
  def COVERAGE_PATH = "sonarqube-generic-coverage.xml";

  try {
    stage('Preparation') { // for display purposes
      // Get code from a GitHub repository
      git branch: env.BRANCH_NAME, credentialsId: 'SS', url: REPO_URL
      ts = sh(script: "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh '${env.STAGE_NAME}' 0 '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'", returnStdout: true )
      sh "rm -rf sonar-reports"
      sh "rm -rf reports/*"
      sh "rm -rf Build"
      sh "cp /Users/mobvenserver/sonar-project.properties ."
    }
  } catch (e) {
    slackSend color: '#008000', message: "${SONAR_PROJECT_NAME} : Preparation Step Failed :face_with_symbols_on_mouth: Please Check Email Box :email: "
    sendMail(committerEmail);
    throw e
  }

  try {
    stage('Test') {
       sh "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh '${env.STAGE_NAME}' '${ts}' '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'"
       sh "xcodebuild -scheme OneLink -sdk iphonesimulator -derivedDataPath Build/ -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.4' test -enableCodeCoverage YES"

    }
  } catch (e) {
    slackSend color: '#008000', message: "${SONAR_PROJECT_NAME} : Test Step Failed :face_with_symbols_on_mouth: Please Check Email Box :email: "
    sendMail(committerEmail);
    throw e
  }

  try {
    stage('Coverage Generation') {
       sh "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh '${env.STAGE_NAME}' '${ts}' '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'"
       sh "bash xccov-to-sonarqube-generic.sh Build/Logs/Test/*.xcresult/ > sonarqube-generic-coverage.xml"
    }
  } catch (e) {
    slackSend color: '#008000', message: "${SONAR_PROJECT_NAME} : Coverage Generation Step Failed :face_with_symbols_on_mouth: Please Check Email Box :email: "
    sendMail(committerEmail);
    throw e
  }

  try {
    stage('Quality Check') {
      sh "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh '${env.STAGE_NAME}' '${ts}' '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'"
      withSonarQubeEnv('LocalSonarQube'){ // SonarQube taskId is automatically attached to the pipeline context
      sh "sonar-scanner -Dsonar.host.url=${SONAR_URL} -Dsonar.login=${SONAR_KEY} -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.coverageReportPaths=${COVERAGE_PATH} -Dsonar.cfamily.build-wrapper-output.bypass=true"
      }
    }
  } catch (e) {
    slackSend color: '#008000', message: "${SONAR_PROJECT_NAME} : Quality Check Step Failed :face_with_symbols_on_mouth: Please Check Email Box :email: "
    sendMail(committerEmail);
    throw e
  }

    stage('Quality Gate'){
      sh "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh '${env.STAGE_NAME}' '${ts}' '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'"
      sleep(5) // Just in case something goes wrong, pipeline will be killed after a timeout
      def qg = waitForQualityGate()
      waitForQualityGate abortPipline: true // Reuse taskId previously collected by withSonarQubeEnv
      if (qg.status != 'OK') {
          sh "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh 'ErrorSQ2' '${ts}' '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'"
          error "Pipeline aborted due to quality gate failure: ${qg.status}"
        }
    }
    sh "bash /Users/mobvenserver/.jenkins/workspace/slack-message-broker.sh 'Success' '${ts}' '${SONAR_PROJECT_NAME}' '${env.BUILD_NUMBER}' '${env.BUILD_URL}' '${committerName}' '${env.BRANCH_NAME}' '${PROJECT_ICON}'"
}
