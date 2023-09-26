# variables.tf

variable "myregion" {
  description = "La région AWS dans laquelle déployer les ressources."
  type        = string
  default     = "us-east-1" # Vous pouvez définir une valeur par défaut ou la laisser vide
}

variable "accountId" {
  description = "L'ID de compte AWS à utiliser pour les ressources."
  type        = string
  default     = "123456789" # Remplacez par votre ID de compte AWS
}