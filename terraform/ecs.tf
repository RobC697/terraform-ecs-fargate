# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "crossfeed-staging-cluster"
}

data "aws_iam_role" "ecs_task_exe_role" { 
  name = var.ecs_task_exe_role 
}

data "template_file" "crossfeed_staging_task_template" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "crossfeed_stage_task_def" {
  family                   = "crossfeed_staging_task_def"
  execution_role_arn       = data.aws_iam_role.ecs_task_exe_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_exe_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.crossfeed_staging_task_template.rendered

  tags =  {
    Name  = "Crossfeed_Stage_Task_Def"
  }
}

resource "aws_ecs_service" "main" {
  name            = "crossfeed_staging_service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.crossfeed_stage_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    //target_group_arn = aws_ecs_task_definition.crossfeed_stage_task_def.task_role_arn
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "Crossfeed_Staging"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end]
}

