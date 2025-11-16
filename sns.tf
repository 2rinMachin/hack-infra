resource "aws_sns_topic" "incident_notifications" {
  name         = "incident-notifications"
  display_name = "Incident notifications"
}
