node default {
  notify { "Running puppet on this system:\nhostname='${facts['hostname']}',\nos.family='${facts['os']['family']}'": }
  include ::profile
}
