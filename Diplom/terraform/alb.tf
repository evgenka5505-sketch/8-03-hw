# Target Group
resource "yandex_alb_target_group" "web-tg" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.private-a.id
    ip_address = yandex_compute_instance.web-1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private-b.id
    ip_address = yandex_compute_instance.web-2.network_interface.0.ip_address
  }
}

# Backend Group
resource "yandex_alb_backend_group" "web-bg" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web-tg.id]

    healthcheck {
      timeout  = "5s"
      interval = "10s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP Router
resource "yandex_alb_http_router" "web-router" {
  name = "web-http-router"
}

resource "yandex_alb_virtual_host" "web-vhost" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web-router.id

  route {
    name = "main-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-bg.id
        timeout          = "5s"
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "web-alb" {
  name               = "web-alb"
  network_id         = yandex_vpc_network.diplom.id
  security_group_ids = [yandex_vpc_security_group.alb-sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public-b.id
    }
  }

  listener {
    name = "http-listener"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
      }
    }
  }
}