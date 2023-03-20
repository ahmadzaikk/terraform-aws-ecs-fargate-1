variable "name" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "readonlyRootFilesystem" {
  default     = false
  description = "When this parameter is true, the container is given read-only access to its root file system"
}
variable "containerInsights" {
  description = "Enables container insights if true"
  type        = bool
  default     = false
}
variable "container_cpu" {
  type        = number
  default     = null
  description = "How much CPU to give the container. 1024 is 1 CPU"
}

variable "container_memory" {
  type        = number
  default     = null
  description = "How much memory in megabytes to give the container"
}
variable "enable_ecs_cluster" {
  description = "Set to false to prevent the module from creating ecs cluster"
  type        = bool
  default     = true
}
variable "environment" {
  description = "List of port objects that the container exposes in addition to the task_container_port."
  type = list(object({
    name = string
    value      = string
  }))
  default = []
}
variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "secrets" {
  description = "List of port objects that the container exposes in addition to the task_container_port."
  type = list(object({
    name = string
    valueFrom = string
  }))
  default = []
}
variable "log_group_name" {
  description = "The name of the provided CloudWatch Logs log group to use."
  default     = ""
  type        = string
}
variable "log_multiline_pattern" {
  description = "Optional regular expression. Log messages will consist of a line that matches expression and any following lines that don't"
  default     = ""
  type        = string
}
variable "alb_sg" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
}

variable "image" {
  description = "Task def image name"
  type        = string
}
variable "stop_timeout" {
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own. On Fargate the maximum value is 120 seconds."
  default     = 30
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance"
  default     = false
  type        = bool
}
variable "volumes" {
  description = "List of volume"
  type        = list(any)
  default     = []
}
variable "sidecar_containers" {
  description = "List of sidecar containers"
  type        = list(any)
  default     = []
}

variable "task_container_command" {
  description = "The command that is passed to the container."
  default     = []
  type        = list(string)
}

variable "task_container_port" {
  description = "Port that the container exposes."
  type        = number
  default     = 0
}

variable "retention_in_days" {
  description = "log group retention."
  default     = 30
  type        = number
}
variable "container_port" {
  description = "Port that the container exposes."
  type        = number
 
}

variable "enable_execute_command" {
  description = "(Optional) If true, autoscaling alarms will be created."
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "(Optional) If true, autoscaling alarms will be created."
  type        = bool
  default     = true
}
variable "max_cpu_threshold" {
  description = "Threshold for max CPU usage"
  default     = "85"
  type        = string
}
variable "min_cpu_threshold" {
  description = "Threshold for min CPU usage"
  default     = "10"
  type        = string
}

variable "max_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
  default     = "3"
  type        = string
}
variable "min_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
  default     = "3"
  type        = string
}

variable "max_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
  default     = "60"
  type        = string
}
variable "min_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for min cpu metric alarm"
  default     = "60"
  type        = string
}

variable "scale_target_max_capacity" {
  description = "The max capacity of the scalable target"
  default     = 2
  type        = number
}

variable "scale_target_min_capacity" {
  description = "The min capacity of the scalable target"
  default     = 1
  type        = number
}

variable "task_container_port_mappings" {
  description = "List of port objects that the container exposes in addition to the task_container_port."
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "task_container_protocol" {
  description = "Protocol that the container exposes."
  default     = "HTTP"
  type        = string
}
variable "efs_volumes" {
  description = "Volumes definitions"
  default     = []
  type = list(object({
    name            = string
    file_system_id  = string
    root_directory  = string
    mount_point     = string
    readOnly        = bool
    access_point_id = string
  }))
}
variable "mount_points" {
  description = "List of mount points"
  type        = list(any)
  default     = []
}
variable "efs_file_system_id" {
  description = "Task def image name"
  type        = string
  default = ""
}
variable "volume_name" {
type = string
default = ""
}

variable "root_directory" {
type = string
default = ""
}

variable "desired_count" {
  description = ""
  type        = string
}

variable "assign_public_ip" {
  description = ""
  type   = string
  default = "false"
}

variable "deployment_maximum_percent" {
  description = ""
  type        = string
}

variable "deployment_minimum_healthy_percent" {
  description = ""
  type        = string
}

variable "cluster" {
  description = "The resource name."
  type        = string
  default     = null
}

variable "cluster_arn" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "cluster_name" {
  description = "The resource name."
  type        = string
  default     = null
}
variable "security_groups" {
  description = "The security groups to attach to the ecs. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
}


variable "memory" {
  description = "task df memory"
  type        = string
}
variable "cpu" {
  description = "task df cpu"
  type        = string
}

variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
  type        = string
  default     = null
}
variable "subnets" {
  description = "A list of subnets to associate with the ecs . e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
}


variable "target_group_arn" {
  description = "target group arn"
  type        = string
}


variable "linux_parameters" {
  type = object({
  tmpfs = list(object({
    containerPath = string
    mountOptions  = list(string)
    size          = number
  
  }
  
  )
  
  }),

  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default     = null
}
 

