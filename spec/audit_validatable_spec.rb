RSpec.describe DataJanitor::AuditValidatable do
  let(:dummy_model) do
    Class.new do
      include ActiveModel::Model
      extend DataJanitor::AuditValidatable
      attr_accessor :name
      def self.name
        'DummyModel'
      end
    end
  end

  describe '.dj_audit_validations' do
    it 'executes methods as class methods and augments arguments' do
      expect(dummy_model).to receive(:validates).
        with(:name, { on: [:dj_audit], presence: true })

      dummy_model.dj_audit_validations do
        validates :name, presence: true
      end
    end
  end

  describe '.dj_validations' do
    it 'executes methods as class methods and augments arguments' do
      expect(dummy_model).to receive(:validates).
        with(:name, { on: [:dj_audit, :create], presence: true })

      dummy_model.dj_validations do
        validates :name, presence: true
      end
    end
  end

  describe 'validation' do
    let(:dummy_instance) { dummy_model.new(name: '') }

    describe 'standard model validation' do
      it 'fails standard validation' do
        dummy_model.validates :name, presence: true
        expect(dummy_instance.valid?).to eq(false)
        expect(dummy_instance.errors.count).to eq(1)
        expect(dummy_instance.errors[:name]).to eq(["can't be blank"])
      end
    end

    describe 'audit and new record validation' do
      it 'fails dj validations when context :dj_audit' do
        dummy_model.dj_validations do
          validates :name, length: { maximum: 5 }
        end

        dummy_instance.name = 'Long Name!'

        expect(dummy_instance.valid?).to eq(true)
        expect(dummy_instance.valid?(:dj_audit)).to eq(false)
        expect(dummy_instance.errors[:name]).to eq([
          'is too long (maximum is 5 characters)'
        ])
      end

      it 'fails dj validations when context :create' do
        dummy_model.dj_validations do
          validates :name, length: { maximum: 5 }
        end

        dummy_instance.name = 'Long Name!'

        expect(dummy_instance.valid?).to eq(true)
        expect(dummy_instance.valid?(:create)).to eq(false)
        expect(dummy_instance.errors[:name]).to eq([
          'is too long (maximum is 5 characters)'
        ])
      end
    end

    describe 'audit and new record validation' do
      it 'fails dj audit validations when context :dj_audit' do
        dummy_model.dj_audit_validations do
          validates :name, length: { maximum: 5 }
        end

        dummy_instance.name = 'Long Name!'

        expect(dummy_instance.valid?).to eq(true)
        expect(dummy_instance.valid?(:dj_audit)).to eq(false)
        expect(dummy_instance.errors.count).to eq(1)
        expect(dummy_instance.errors[:name]).to eq([
          'is too long (maximum is 5 characters)'
        ])
      end
    end
  end
end
