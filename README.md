# RailsConfig

THIS IS A FORK! 

This variant of the `rails_config` gem uses a much easier to understand and
therefore easier to use and more reliable deep-merge strategy. The key 
property can be summarized in the following sentence:  

** Values which are to be merged in and are not maps/hashes always overwrite
exiting values. **


The formal descriptions reads as follows: 


Let `M1` and `M2` be a maps, and let `M` be the result of `deep_merge M1 M2`
Then the  following holds true:

1. If the key `k` with the value `v1` is present in `M1` but not in `M2`, then
  the key value pair `(k,v1)` is be present in `M`.

2. If the key `k` with the value `v2` is present in `M2` but not in `M1`, then
  the key value pair `(k,v2)` is be present in `M`.

3. If `k` is present in `M1` and `M2`

    1. and  `v1` and `v2` are both maps, then the pair `(k,  deep_merge v1 v2 )` is present in `M`.

    2. otherwise the pair `(k,v2)` is present in `M`.


The implementation comprises about 30 lines whereas the original one extends to
about 180 lines including some rather diffuse comments. 



## Summary

RailsConfig helps you easily manage environment specific Rails settings in an easy and usable manner

## Features

* simple YAML config files
* config files support ERB
* config files support inheritance
* access config information via convenient object member notation

## Compatibility

* Rails 3.x and 4.x
* Padrino
* Sinatra

For older versions of Rails and other Ruby apps, use [AppConfig](http://github.com/fredwu/app_config).

## Installing on Rails 3 or 4

Add this to your `Gemfile`:

```ruby
gem "rails_config"
```

## Installing on Padrino

Add this to your `Gemfile`:

```ruby
gem "rails_config"
```

in your app.rb, you'll also need to register RailsConfig

```ruby
register RailsConfig
```

## Installing on Sinatra

Add this to your `Gemfile`:

```ruby
gem "rails_config"
```

in your app, you'll need to register RailsConfig. You'll also need to give it a root so it can find the config files.

```ruby
set :root, File.dirname(__FILE__)
register RailsConfig
```

It's also possible to initialize it manually within your configure block if you want to just give it some yml paths to load from.

```ruby
RailsConfig.load_and_set_settings("/path/to/yaml1", "/path/to/yaml2", ...)
```

## Customizing RailsConfig

You may customize the behavior of RailsConfig by generating an initializer file:

    rails g rails_config:install

This will generate `config/initializers/rails_config.rb` with a set of default settings as well as to generate a set of default settings files:

    config/settings.yml
    config/settings/development.yml
    config/settings/production.yml
    config/settings/test.yml

## Accessing the Settings object

After installing this plugin, the `Settings` object will be available globally. Entries are accessed via object member notation:

```ruby
Settings.my_config_entry
```

Nested entries are supported:

```ruby
Settings.my_section.some_entry
```

Alternatively, you can also use the `[]` operator if you don't know which exact setting you need to access ahead of time.

```ruby
# All the following are equivalent to Settings.my_section.some_entry
Settings.my_section[:some_entry]
Settings.my_section['some_entry']
Settings[:my_section][:some_entry]
```

If you have set a different constant name for the object in the initializer file, use that instead.

## Common config file

Config entries are compiled from:

    config/settings.yml
    config/settings/#{environment}.yml
    config/environments/#{environment}.yml

    config/settings.local.yml
    config/settings/#{environment}.local.yml
    config/environments/#{environment}.local.yml

Settings defined in files that are lower in the list override settings higher.

### Reloading settings

You can reload the Settings object at any time by running `Settings.reload!`.

### Reloading settings and config files

You can also reload the `Settings` object from different config files at runtime.

For example, in your tests if you want to test the production settings, you can:

```ruby
Rails.env = "production"
Settings.reload_from_files(
  Rails.root.join("config", "settings.yml").to_s,
  Rails.root.join("config", "settings", "#{Rails.env}.yml").to_s,
  Rails.root.join("config", "environments", "#{Rails.env}.yml").to_s
)
```

### Environment specific config files

You can have environment specific config files. Environment specific config entries take precedence over common config entries.

Example development environment config file:

```ruby
#{Rails.root}/config/environments/development.yml
```

Example production environment config file:

```ruby
#{Rails.root}/config/environments/production.yml
```

### Developer specific config files

If you want to have local settings, specific to your machine or development environment,
you can use the following files, which are automatically `.gitignored` :

    Rails.root.join("config", "settings.local.yml").to_s,
    Rails.root.join("config", "settings", "#{Rails.env}.local.yml").to_s,
    Rails.root.join("config", "environments", "#{Rails.env}.local.yml").to_s


### Adding sources at Runtime

You can add new YAML config files at runtime. Just use:

```ruby
Settings.add_source!("/path/to/source.yml")
Settings.reload!
```

This will use the given source.yml file and use its settings to overwrite any previous ones.

One thing I like to do for my Rails projects is provide a local.yml config file that is .gitignored (so its independent per developer). Then I create a new initializer in `config/initializers/add_local_config.rb` with the contents

```ruby
Settings.add_source!("#{Rails.root}/config/settings/local.yml")
Settings.reload!
```

> Note: this is an example usage, it is easier to just use the default local files `settings.local.yml, settings/#{Rails.env}.local.yml and environments/#{Rails.env}.local.yml`
>       for your developer specific settings.

## Embedded Ruby (ERB)

Embedded Ruby is allowed in the configuration files. See examples below.

## Accessing Configuration Settings

Consider the two following config files.

 #{Rails.root}/config/settings.yml:

```yaml
size: 1
server: google.com
```

 #{Rails.root}/config/environments/development.yml:

```yaml
size: 2
computed: <%= 1 + 2 + 3 %>
section:
  size: 3
  servers: [ {name: yahoo.com}, {name: amazon.com} ]
```

Notice that the environment specific config entries overwrite the common entries.

```ruby
Settings.size   # => 2
Settings.server # => google.com
```

Notice the embedded Ruby.

```ruby
Settings.computed # => 6
```

Notice that object member notation is maintained even in nested entries.

```ruby
Settings.section.size # => 3
```

Notice array notation and object member notation is maintained.

```ruby
Settings.section.servers[0].name # => yahoo.com
Settings.section.servers[1].name # => amazon.com
```

## Working with Heroku

Heroku uses ENV object to store sensitive settings which are like the local files described above. You cannot upload such files to Heroku because it's ephemeral filesystem gets recreated from the git sources on each instance refresh.

To use rails_config with Heroku just set the `use_env` var to `true` in your `config/initializers/rails_config.rb` file. Eg:

```ruby
RailsConfig.setup do |config|
  config.const_name = 'AppSettings'
  config.use_env = true
end
```

Now rails_config would read values from the ENV object to the settings. For the example above it would look for keys starting with 'AppSettings'. Eg:

```ruby
ENV['AppSettings.section.size'] = 1
ENV['AppSettings.section.server'] = 'google.com'
```

It won't work with arrays, though.

To upload your local values to Heroku you could ran `bundle exec rake rails_config:heroku`.


## Contributing

Bootstrap

```bash
$ appraisal install
```

Running the test suite

```bash
$ appraisal rspec
```


## Authors

* [Jacques Crocker](http://github.com/railsjedi)
* [Fred Wu](http://github.com/fredwu)
* [Piotr Kuczynski](http://github.com/pkuczynski)
* Inherited from [AppConfig](http://github.com/cjbottaro/app_config) by [Christopher J. Bottaro](http://github.com/cjbottaro)

## License

RailsConfig is released under the [MIT License](http://www.opensource.org/licenses/MIT).
