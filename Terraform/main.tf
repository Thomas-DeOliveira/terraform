data "azurerm_resource_group" "rg" {
  name = "rg-TDeOliveira2024_cours-azure-kubernetes"
}
resource "azurerm_kubernetes_cluster" "k8s" {    # dÃ©tails : az aks show -n cluster-yc -g rg-ycadin_cours-azure-kubernetes
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "cluster-td"
  dns_prefix          = "k8s-td-noeud"   # prÃ©fixe des noms des nÅ“uds crÃ©Ã©s
  identity {
    type = "SystemAssigned"              # ou "UserAssigned"
  }
  default_node_pool {
    name = "default"                # nom du pool de nÅ“uds par dÃ©faut
    vm_size    = "Standard_B2S"        # 2 CPUs 4 GiO (ancienne dÃ©signation : Standard_D2_v2 pour 2 CPUs 7 GiO)
    node_count = var.node_count          # facultatif (3 par dÃ©faut)
  }
  network_profile {
    network_plugin = "kubenet"           # valeurs possibles : azure, kubenet ou none
    network_policy = "calico"            # none par dÃ©faut ; requis pour que les NetworkPolicies de Kubernetes aient un effet
  }
  tags = {
    user = "TDeOliveira2024"
  }
}