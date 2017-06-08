module DataJanitor
  module UniversalValidator
    # TODO: Disabled until we decide to apply this condition as a standard validation
    # TODO: Run standard validators instead of home-brewed
    # validate :validate_field_values
    # ACCEPTABLE_BOOLEAN_VALUES = %w(t true y yes on 1 f false n no off 0) # this list was taken from Postgres spec. TRUE FALSE, that are also there, are not listed because they are DB-native literals and have no representation in Ruby code
    def validate_field_values
      # selected_attributes = self.changed? ? self.changed_attributes : self.attributes
      selected_attributes = self.attributes

      selected_attributes.each do |field_name, field_val|
        column = self.column_for_attribute field_name
        report_error = lambda {|msg| errors[column.name] << msg}

        if column.array
          report_error.call "cannot be nil" if field_val.nil?
          next
        end

        case column.type
        when :boolean
          report_error.call "cannot be nil" if field_val.nil?
          # report_error.call("must be a valid boolean") unless ACCEPTABLE_BOOLEAN_VALUES.include? field_val
        when :date
          # Date.iso8601(field_val) rescue report_error.call("must be a date in ISO-8601")
        when :time
          # Time.iso8601(field_val) rescue report_error.call("must be a datetime in ISO-8601")
        when :datetime
          # Time.iso8601(field_val) rescue report_error.call("must be a datetime in ISO-8601")
        when :decimal
          report_error.call "cannot be nil" if field_val.nil?
          # TODO: run numericality test
        when :float
          report_error.call "cannot be nil" if field_val.nil?
          # TODO: run numericality test
        when :integer
          report_error.call "cannot be nil" if field_val.nil?
          # TODO: run numericality test
        when :string, :text
          if field_val.nil?
            report_error.call "cannot be nil. Use an empty string instead if that's what you wanted."
          else
            report_error.call "cannot have leading/trailing whitespaces" if field_val =~ /^\s/ || field_val =~ /\s$/
            # TODO: Should we constrain to certain encoding types?
          end
        end
      end
    end
  end
end
