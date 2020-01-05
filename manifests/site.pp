node default {
  notify { "\nRunning puppet on this system:\nhostname='${facts['hostname']}',\nos.family='${facts['os']['family']}'\n": }
  include ::profile
}
