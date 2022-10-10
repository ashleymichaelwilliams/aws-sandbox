terramate {
  required_version = "~> 0.1.35"

  config {
    git {
      default_branch = "master"
    }
    run {
      env {
        TF_PLUGIN_CACHE_DIR = "${terramate.root.path.fs.absolute}/.terraform-cache-dir"
      }
    }
  }
}
