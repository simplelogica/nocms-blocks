shared_examples_for "model with required attributes" do |model_name, required_attribute_names|

  context "validations" do

    # we go through the required attributes and for each one we create a context where it's set to nil and we check the object is not valid and there's an error on the attributes
    required_attribute_names.each do |attribute_name|

      context "with empty #{attribute_name}" do

        let(:model_object) { build model_name, attribute_name => nil }
        before { model_object.valid? }
        subject { model_object }

        it { should_not be_valid }
        it { expect(subject.error_on(attribute_name)).to include I18n.t('errors.messages.blank') }
      end

    end
  end

end
