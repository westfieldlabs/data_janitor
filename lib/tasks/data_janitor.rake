namespace :data_janitor do
  desc 'Summarize invalid database records'
  task :audit, [:output_file, :verbose, :unscoped, :options] => [:environment] do |_t, args|
    args.with_defaults(
      output_file: Rails.root.join('tmp', 'data_janitor_results.json'),
      verbose: 'false',
      unscoped: 'false',
      options: 'no-type-check'
    )
    verbose = args[:verbose] == 'true'
    unscoped = args[:unscoped] == 'true'

    Rails.application.eager_load!
    DataJanitor::audit(args[:output_file], verbose, unscoped, args[:options])
  end

  desc 'Audit one model for data issues'
  task :audit_model, [:model, :options] => [:environment] do |_t, args|
    args.with_defaults(
      options: 'no-type-check'
    )
    Rails.application.eager_load!
    DataJanitor::audit_model args[:model].constantize, {}, true, false, args[:options]
  end

  # For each model, apply trivial data corrections (those that do not require looking at data semantics).
  # This includes:
  # - replace all null strings with empty strings
  # - replace all null booleans with false
  # - replace all null arrays with []
  desc 'Apply common and safe data corrections'
  task cleanse: :environment do
    Rails.application.eager_load!
    DataJanitor::clense
  end

  desc 'Apply fixes to one model only'
  task :cleanse_model, [:model] => [:environment] do |_t, args|
    Rails.application.eager_load!
    DataJanitor::clense_model args[:model].constantize
  end

end
