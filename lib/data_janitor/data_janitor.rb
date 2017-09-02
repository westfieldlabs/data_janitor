module DataJanitor
  def self.audit(output_file, verbose, unscoped, options)
    output = {}
    all_models.each do |ar_model|
      begin
        audit_model ar_model, output, verbose, unscoped, options
      rescue ActiveRecord::StatementInvalid # used to catch HABTM and schema migration. Only care about real Models
        puts "skipping #{ar_model}"
      end
    end

    File.write(output_file, output.to_json)

    puts "Wrote results to #{output_file}"
  end

  def self.audit_model(model, output = {}, verbose = false, unscoped = false, options = 'no-type-check')
    total = 0
    failed = 0
    puts "Validating: #{model.name}"
    output[model.name] = {}

    model = model.unscoped if unscoped
    model.include(DataJanitor::UniversalValidator)
    model.validate do |record|
      record.validate_field_values options
    end

    model.find_each do |rec|
      if rec.invalid?(:dj_audit)
        rec.errors.to_h.each_pair do |attribute, error_message|
          output[model.name][attribute] ||= {}
          output[model.name][attribute][error_message] ||= []
          output[model.name][attribute][error_message] << rec.id
        end

        failed += 1
      end

      total += 1
    end

    puts output.to_json if verbose
    puts "Completed #{total} records with #{failed} failures"
  end

  def self.cleanse
    all_models.each do |ar_model|
      cleanse_model! ar_model
    end
  end

  def self.cleanse_model(model)
    cleanse_model! model.constantize
  end

  private

  def self.all_models
    # Needs this executed before here: Rails.application.eager_load!
    ActiveRecord::Base.descendants
  end

  def self.cleanse_model!(model)
    string_columns = model.columns.select{|c| (c.type == :string || c.type == :text) && c.array == false}
    boolean_columns = model.columns.select{|c| c.type == :boolean && c.array == false}
    array_columns = model.columns.select{|c| c.array == true}

    clean_nils_from! model, string_columns, ""
    clean_nils_from! model, boolean_columns, false
    clean_nils_from! model, array_columns, []
  end

  def self.clean_nils_from!(model, columns, default)
    columns.each do |column|
      count = model.where(column.name => nil).update_all(column.name => default)
      puts "Fixed #{count} #{model} records where #{column.name} was nil" if count > 0
    end
  end
end
