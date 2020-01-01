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
      env {
        version = "$(SENSOR_VERSION)"
        id = "$(SENSOR_ID)"
        apiUrl = "$(SENSOR_API_URL)"
      }
    }
  }
}