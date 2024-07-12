# --- loadbalancing/outputs.tf ---
output "user-service_tg_arn" {
  value = aws_lb_target_group.user-service.arn
}

output "appointment-service_tg_arn" {
  value = aws_lb_target_group.appointment-service.arn
}

output "notification-service_tg_arn" {
  value = aws_lb_target_group.notification-service.arn
}

output "user-service-int_tg_arn" {
  value = aws_lb_target_group.user-service-int.arn
}

output "appointment-service-int_tg_arn" {
  value = aws_lb_target_group.appointment-service-int.arn
}

output "notification-service-int_tg_arn" {
  value = aws_lb_target_group.notification-service-int.arn
}

output "elb_url" {
  value = aws_lb.loadbalancer.dns_name
}