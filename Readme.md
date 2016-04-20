# kitchen-ansiblepush
A test-kitchen verifier plugin for GOSS 

## Intro
[GOSS](https://github.com/aelsabbahy/goss.git) is a tool for validating a server's configuration. 
This kitchen plugin adds Goss support as a validation to kitchen.

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
```

## kitchen.yml options
Besides the normal config in kitchen.yml goss validation can accept the following options.

```ruby
default_config :sleep, 0
default_config :goss_version, "v0.1.5"
default_config :validate_output, "documentation"
default_config :custom_install_command, nil
default_config :goss_link, "https://github.com/aelsabbahy/goss/releases/download/$VERSION/goss-${DISTRO}-${ARCH}"
default_config :goss_download_path, "/tmp/goss-${VERSION}-${DISTRO}-${ARCH}"
```

##License

MIT