[![Build Status](https://travis-ci.org/westfieldlabs/data_janitor.svg?branch=master)](https://travis-ci.org/westfieldlabs/data_janitor)

# DataJanitor

DataJanitor allows you to run your in-application Active Record validations as well as additional data audit validations across all records in a table or database at will. This is particular helpful in evolving validations and finding which records will no longer pass validation, as well as periodically performing more extensive audit validations without the real-time cost. Additional validations can be written to run only during the audit, or can be also be run during create. This allows time to migrate existing data to the new validation requirements while ensuring new data meets the current validation standards.

DataJanitor also augments your ActiveRecord models (at rake-task runtime) to allow for running project-wide common validations on the data. Thus, it will look at all models in your repository and tell you whether any data was stored that potentially violates the common project data formats. This can happen if a model does not have enough validations of its own or if its validations are not strict enough.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'data_janitor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data_janitor

## Usage

### Custom Model Level Validations

ActiveRecord validations for **Audit Only**

```ruby
class SomeModel < ActiveRecord::Base
  extend DataJanitor::AuditValidatable

  dj_audit_validations do
    # Desired validations
    validates :country, inclusion: { in: ['US', 'AU', 'NZ'] }
  end
end
```
These validations only run when validating with an the ActiveRecord context `:dj_audit` is included, as in `rec.invalid?(:dj_audit)`, so they normally will only be run by the DJ rake tasks.

ActiveRecord validations for **Audit** and **Newly Created Records**

```ruby
class SomeModel < ActiveRecord::Base
  extend DataJanitor::AuditValidatable

  dj_validations do
    validates :name, length: { maximum: 25 }
  end
end
```
These validations are run when validating during create and with an the ActiveRecord context `:dj_audit` is included, as in `rec.invalid?(:dj_audit)`, so they are run by the application as well as by the DJ rake tasks.

### Rake Tasks

To audit the data defined by the ActiveRecord models in your repository:
```
rake data_janitor:audit
rake data_janitor:audit['some/file/path.json']
rake data_janitor:audit['some/file/path.json',true]
```

This will audit your DB for errors and output them to `tmp/data_janitor_results.json` (by default), or a specified path. The report will contain a list of errors with IDs of invalid records for each model. Including `true` will also display the output at the console.

You can also audit a specific model rather than all models found in the repository:

```
rake data_janitor:audit_model[SomeModel]
```

To apply common fixes to all models in your repository:
```
rake data_janitor:cleanse
```

To apply common fixes to just one model:
```
rake data_janitor:cleanse[SomeModel]
```

This will apply all the fixes that do not require semantic analysis of the data (e.g. replace `nil` values with `""` for strings)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/westfield/data_janitor.
