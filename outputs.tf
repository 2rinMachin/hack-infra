output "vm_apache_airflow_ip" {
  description = "Public IP of Apache Airflow VM"
  value       = aws_instance.apache_airflow.public_ip
}

output "incident_notifications_topic_arn" {
  value = aws_sns_topic.incident_notifications.arn
}
