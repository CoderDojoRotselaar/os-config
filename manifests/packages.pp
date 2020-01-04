class packages (
  Array[String] $auto_update = [],
) {
  package { $auto_update:
    ensure => latest,
  }
}
