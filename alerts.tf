provider "newrelic" {
  api_key = "XXXYYYZZZ"
}

resource "newrelic_alert_policy" "apm" {
  name = "${var.app_name} - APM - Production (managed by Terraform)"
}

resource "newrelic_alert_condition" "error_percentage" {
  policy_id       = "${newrelic_alert_policy.apm.id}"
  name            = "${var.app_name} - Error Percentage"
  type            = "apm_app_metric"
  entities        = ["602115"]
  condition_scope = "application"
  metric          = "error_percentage"

  term {
    duration      = 120
    operator      = "above"
    priority      = "critical"
    threshold     = "25"
    time_function = "all"
  }
}

resource "newrelic_alert_policy" "browser" {
  name = "${var.app_name} - Browser - Production (managed by Terraform)"
}

resource "newrelic_alert_condition" "total_page_load" {
  policy_id   = "${newrelic_alert_policy.browser.id}"
  name        = "${var.app_name} - Total Page Load"
  type        = "browser_metric"
  entities    = ["602115"]
  metric      = "total_page_load"
  runbook_url = ""

  term {
    duration      = 120
    operator      = "above"
    priority      = "critical"
    threshold     = "15"
    time_function = "all"
  }
}

resource "newrelic_alert_channel" "email" {
  name = "My Email Channel"
  type = "email"

  configuration = {
    recipients              = "frank@MYSECRETEMAIL.ch"
    include_json_attachment = "0"
  }
}

resource "newrelic_alert_policy_channel" "application_email_alert" {
  policy_id  = "${newrelic_alert_policy.apm.id}"
  channel_id = "${newrelic_alert_channel.email.id}"
}

resource "newrelic_alert_policy_channel" "browser_email_alert" {
  policy_id  = "${newrelic_alert_policy.browser.id}"
  channel_id = "${newrelic_alert_channel.email.id}"
}
