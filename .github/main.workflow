workflow "Build and deploy on push" {
  on = "push"
  resolves = [
    "Login DockerHub",
    "Docker Push"
  ]
}

action "Login DockerHub" {
  uses = "actions/docker/login@86ff551d26008267bb89ac11198ba7f1d807b699"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "Docker Build" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  args = "build -t \"${DOCKER_USERNAME}/zaproxy:latest\" ."
  secrets = ["DOCKER_USERNAME"]
  needs = ["Login DockerHub"]
}

action "Docker Tag" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Build"]
  runs = ["./tag.sh"]
  secrets = ["DOCKER_USERNAME"]
}

action "Docker Push" {
  uses = "actions/docker/cli@86ff551d26008267bb89ac11198ba7f1d807b699"
  needs = ["Docker Tag"]
  args = "push \"${DOCKER_USERNAME}/zaproxy\""
  secrets = ["DOCKER_USERNAME"]
}
