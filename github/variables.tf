variable "gitlab_token" {
  description = "The GitLab token."
  type        = string
}

variable "github_org" {
  description = "The GitHub organization."
  type        = string
}

variable "github_token" {
  description = "The GitHub token."
  type        = string
}

variable "repositories" {
  description = "List of GitHub repositories to migrate."
  type        = list(string)
}

variable "gitlab_group_id" {
  description = "The GitLab group ID."
  type        = number
}

variable "release_tag" {
  description = "Release tag to migrate"
  type        = string
}
