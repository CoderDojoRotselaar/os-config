node default {
  notify { "Running puppet on this system: '${facts['hostname']}', '${facts['os']['name']}'": }
  include ::profile
}
