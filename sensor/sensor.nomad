job "sensor" {
  datacenters = ["dc1"]
  type = "service"
  group "sensor-group" {
    count = 1
    task "sensor-app" {
      driver = "raw_exec"
      config {
        command = "/main"
      }
      template {
        data = <<EOH
        api_host="{{key "sensor/api_host"}}"
        version="{{key "sensor/version"}}"
        id="{{key "sensor/id"}}"
        x_start="{{key "sensor/x_start"}}"
        y_start="{{key "sensor/y_start"}}"
        EOH
        env = true
        destination = "local/env.txt"
      }
    }
  }
}