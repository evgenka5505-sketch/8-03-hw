terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = "b1gcc786qjf1j87j6qf6"
  folder_id                = "b1g43ce6hopio3mf9ds7"
  zone                     = "ru-central1-a"
}