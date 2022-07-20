

resource "aws_ecs_task_definition" "this" {
  family                   = join("-", [var.name, "task"]) # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.name}",
      "image": "${var.image}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.containerport},
          "hostPort": ${var.hostport}
        }
      ],
      "memory": ${var.memory},
      "cpu": ${var.cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory        # Specifying the memory our container requires
  cpu                      = var.cpu         # Specifying the CPU our container requires
  execution_role_arn       = var.execution_role_arn
}


### ECS Services

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
  depends_on      = [aws_ecs_task_definition.this]
}
resource "aws_ecs_service" "this" {
  name = join("-", [var.name, "service"])
  # task_definition = "${aws_ecs_task_definition.this.id}"
  task_definition = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  cluster         = var.cluster

  load_balancer {
    target_group_arn = var.target_group_arn
    #target_group_arn = var.target_group_arn
    # target_group_arn = "${aws_lb_target_group.this[0].arn}"
    # target_group_arn = "${aws_lb_target_group.blue.arn}"
    container_name   = var.name
    container_port   = var.containerport
   
  }

  launch_type                        = "FARGATE"
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  network_configuration {
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip # Providing our containers with public IPs
    security_groups   = var.security_groups
  }
  lifecycle {
    ignore_changes = [task_definition,load_balancer,network_configuration]
    # create_before_destroy = true
  }

  #depends_on = [var.http_tcp_listener_arns]
}


## Autoscaling


resource "aws_appautoscaling_target" "target" {
  service_namespace  = join("-", [var.name, "autoscale"])
  resource_id        = "service/var.cluster/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "arn:aws:iam::944706592399:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling_kk-test"
  min_capacity       = 1
  max_capacity       = 4
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {
  name               = "cb_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/var.cluster/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  name               = "cb_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/var.cluster/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.cluster
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = var.cluster
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}

# resource "aws_security_group" "service_security_group" {
#   name = "kk-ecs-test"
#   vpc_id      = "vpc-06a0bfef01b9d0e7b"
#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     # Only allowing traffic in from the load balancer security group
#     security_groups = [""]
#   }

#   egress {
#     from_port   = 0 # Allowing any incoming port
#     to_port     = 0 # Allowing any outgoing port
#     protocol    = "-1" # Allowing any outgoing protocol 
#     cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
#   }
# }
