variable "resource_group_location" {
  default     = "francecentral"   # az account list-locations | jq '[ .[] | select(.name | startswith("france")).name ] | sort'
  description = "Localisation gÃ©ographique du groupe de ressources"
}
variable "node_count" {
  default     = 3   # compter environ 10 minutes pour crÃ©er le cluster
  description = "QuantitÃ© initiale de nÅ“uds pour la rÃ©serve (pool)"
}