variable "aws_region" {
  description = "Region AWS pour le deploiement des ressources"
  type        = string
  default     = "eu-west-3"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "image_tag" {
  description = "Tag de l'image Docker a deployer"
  type        = string
  default     = "latest"
}

variable "github_repo" {
  description = "Nom du depot GitHub"
  type        = string
  default     = "devops-pipeline"
}

variable "github_token" {
  description = "Token GitHub pour l'acces au registre"
  type        = string
  sensitive   = true
}

variable "ssh_allowed_cidrs" {
  description = "Blocs CIDR autorises pour l'acces SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
