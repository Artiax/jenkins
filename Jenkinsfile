def image;
def commit;

echo "Spawning a slave for this job..."

node("docker") {
    stage("Clone") {
        git branch: 'master', url: "https://github.com/Artiax/jenkins.git", changelog: false, poll: false
    }

    stage("Build") {
        image = docker.build "jenkins"
    }

    stage("Tag") {
        commit = sh(returnStdout: true, script: "git rev-parse HEAD").trim().take(8)

        image.tag "${commit}"
        image.tag "latest"
    }
}

timeout(time: 15, unit: 'MINUTES') {
    try {
        input(id: 'deploy', message: 'Deploy this image?')
        build job: 'deployments/jenkins', parameters: [string(name: 'TAG', value: "${commit}")], wait: false
    } catch(err) {
        currentBuild.result = 'SUCCESS'
    }
}
