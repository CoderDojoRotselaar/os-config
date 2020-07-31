# Quickstart

Run the deploy script in a terminal of a freshly installed system:

```bash
curl -sSL https://raw.githubusercontent.com/CoderDojoRotselaar/os-config/master/bootstrap/deploy.sh | \
  tee /tmp/deploy.sh && \
  sudo -E bash /tmp/deploy.sh
```

Note: this script will run as root and WILL change your system! It may delete your pictures, upload your private live and perhaps eat your children too... I suggest reviewing the content of this script before actually running it. Or run it, as suggested, on a clean, freshly installed system.

# Expected pre-state

As clean as possible. We need Internet, and either:

- a user 'coderdojo' with uid `1000`
- no user with uid `1000`

The user you run the above command with, should have `sudo` capabilities.

# Supported operating systems

- Debian family:
  - Linux Lite 4.6 (<https://www.linuxliteos.com/>)
  - Ubuntu 18.04.3 Desktop LTS (<https://www.ubuntu.com/>)

- RedHat family:
  - Fedora Workstation 31 (<https://fedoraproject.org/>)

# Installing new devices

See: [this repository](https://github.com/CoderDojoRotselaar/bootstrapping)
