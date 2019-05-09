# kitchen-goss
[![Gem Version](https://badge.fury.io/rb/kitchen-goss.svg)](https://badge.fury.io/rb/kitchen-goss)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/kitchen-goss?type=total&color=brightgreen)](https://rubygems.org/gems/kitchen-goss)

A test-kitchen verifier plugin for GOSS

## Intro
[GOSS](https://github.com/aelsabbahy/goss.git) is a tool for validating a server's configuration.
This kitchen plugin adds Goss support as a validation to kitchen. Since GOSS is written in GO lang. This plugin use sftp to push tests to remote machines no ruby is needed to run verify.


## How to install

### Ruby gem
```
gem install kitchen-goss
```

### To install from code or develop
```
git clone git@github.com:ahelal/kitchen-goss.git
cd kitchen-goss
gem build kitchen-goss.gemspec
gem install kitchen-goss-<version>.gem
```

## kitchen.yml configuration
```yaml
verifier                    :
  name                      : "goss"
  sleep                     : 0
  use_sudo                  : true
  goss_version              : "v0.3.6"
  goss_link                 : "https://github.com/aelsabbahy/goss/releases/download/$VERSION/goss-linux-${ARCH}"
  goss_var_path             : "common.yml"
  env_vars                  : {"test_uid": 123}
```

## kitchen.yml options
Besides the normal config in kitchen.yml goss validation can accept the following options.

```ruby
default_config :sleep, 0
default_config :use_sudo, false
default_config :env_vars, {}
default_config :goss_version, "v0.1.5"
default_config :validate_output, "documentation"
default_config :custom_install_command, nil
default_config :goss_link, "https://github.com/aelsabbahy/goss/releases/download/$VERSION/goss-${DISTRO}-${ARCH}"
default_config :goss_download_path, "/tmp/goss-${VERSION}-${DISTRO}-${ARCH}"
default_config :goss_var_path, nil
```

## Test structure

Lets say you have a suite name **simple** all yaml files will be uses for testing.


```bash
.kitchen.yml
test/
  \_integration/
    \_simple/
      \_goss/
        \_test1.yml
        |_test2.yml
        |_common.yml  # --vars common.yml with .Vars render, not for goss test
```


## License

MIT
