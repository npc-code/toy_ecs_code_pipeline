provider "aws" {
  profile = "test"
  region  = "us-east-1"
  alias   = "test"
}


module "under_test" {
    source = "../.."
    cluster_name = "test-cluster"
    container_name = "test-container"
    container_port = 5000
    environment_variables = {
        foo = "bar",
        bar = "foo"
    }
    desired_task_cpu = "test"
    desired_task_memory = "test"
    desired_tasks = 2
    external_ip = "test"
    vpc_id = "test"
    alb_port = 80
    region = "us-east-1"
    ecr_repo_name = "test-ecr-repo"
    subnets = ["test1", "test2"]
    
    providers = {
        aws = aws.test
    }
}