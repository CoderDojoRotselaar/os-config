# Quickstart

Run the deploy script in a terminal of a freshly installed system:

```bash
curl -sSL https://raw.githubusercontent.com/CoderDojoRotselaar/os-config/master/deploy.sh > /tmp/deploy.sh && \
       sudo -E bash /tmp/deploy.sh
```

Note: this script will run as root and WILL change your system! It may delete your pictures, upload your private live and perhaps eat your children too... I suggest reviewing the content of this script before actually running it. Or run it, as suggested, on a clean, freshly installed system.

# Expected state

As clean as possible. We need Internet, and either:

* a user 'coderdojo' with uid `1000`
* no user with uid `1000`

# Supported operating systems

* Debian family:
  * Ubuntu (<https://www.ubuntu.com/>)
  * Linux Lite (<https://www.linuxliteos.com/>)

* RedHat family:
  * Fedora (<https://fedoraproject.org/>)
