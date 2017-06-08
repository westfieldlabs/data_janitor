namespace :data_janitor do
  desc 'Summarize invalid database records'
  task :audit, [:output_file, :verbose, :unscoped] => [:environment] do |_t, args|
    args.with_defaults(
      output_file: Rails.root.join('tmp', 'data_janitor_results.json'),
      verbose: false,
      unscoped: false
    )

    output = {}
    all_models.each do |ar_model|
      begin
        audit ar_model, output, args[:verbose], args[:unscoped]
      rescue ActiveRecord::StatementInvalid # used to catch HABTM and schema migration. Only care about real Models
        puts "skipping #{ar_model}"
      end
    end

    File.write(args[:output_file], output.to_json)

    puts "Wrote results to #{args[:output_file]}"
  end

  desc 'Audit one model for data issues'
  task :audit_model, [:model] => [:environment] do |_t, args|
    Rails.application.eager_load!
    audit args[:model].constantize, {}, true
  end

  # For each model, apply trivial data corrections (those that do not require looking at data semantics).
  # This includes:
  # - replace all null strings with empty strings
  # - replace all null booleans with false
  # - replace all null arrays with []
  desc 'Apply common and safe data corrections'
  task cleanse: :environment do
    all_models.each do |ar_model|
      cleanse_model! ar_model
    end
  end

  desc 'Apply fixes to one model only'
  task :cleanse_model, [:model] => [:environment] do |_t, args|
    Rails.application.eager_load!

    cleanse_model! args[:model].constantize
  end

  private

  def all_models
    Rails.application.eager_load!
    ActiveRecord::Base.descendants
  end

  def audit(model, output = {}, verbose = false, unscoped = false)
    total = 0
    failed = 0
    puts "Validating: #{model.name}"
    output[model.to_s] = {}
    model = model.unscoped if unscoped

    model.include(DataJanitor::UniversalValidator)
    model.validate :validate_field_values

    model.find_each do |rec|
      if rec.invalid?(:dj_audit)
        rec.errors.to_h.each_pair do |attribute, error_message|
          output[model.to_s][attribute] ||= {}
          output[model.to_s][attribute][error_message] ||= []
          output[model.to_s][attribute][error_message] << rec.id
        end

        failed += 1
      end

      total += 1
    end

    puts output.to_json if verbose
    puts "Completed #{total} records with #{failed} failures"
  end

  def cleanse_model!(model)
    string_columns = model.columns.select{|c| (c.type == :string || c.type == :text) && c.array == false}
    boolean_columns = model.columns.select{|c| c.type == :boolean && c.array == false}
    array_columns = model.columns.select{|c| c.array == true}

    clean_nils_from! model, string_columns, ""
    clean_nils_from! model, boolean_columns, false
    clean_nils_from! model, array_columns, []
  end

  def clean_nils_from!(model, columns, default)
    columns.each do |column|
      count = model.where(column.name => nil).update_all(column.name => default)
      puts "Fixed #{count} #{model} records where #{column.name} was nil" if count > 0
    end
  end
end
