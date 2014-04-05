shared_examples_for "model with has many relationship" do |model_name, related_model_factory, has_many_relationship, belongs_to_relationship|

  context "when creating various #{has_many_relationship}" do

    let(:model_object) { create model_name }
    let(:related_object_1)  { create related_model_factory, belongs_to_relationship => model_object }
    let(:related_object_2)  { create related_model_factory, belongs_to_relationship => model_object }

    before do
      related_object_1 && related_object_2
    end

    subject { model_object }

    it("should relate to all of its #{has_many_relationship}") { expect(subject.send(has_many_relationship.to_sym)).to match_array [related_object_1, related_object_2] }

    context "related #{has_many_relationship.to_s.singularize}" do

      subject { related_object_1 }

      it("should relate to the original #{belongs_to_relationship}") {
        expect(subject.send(belongs_to_relationship.to_sym)).to eq model_object
      }

    end

    context "related #{has_many_relationship.to_s.singularize}" do

      subject { related_object_2 }

      it("should relate to the original #{belongs_to_relationship}") {
        expect(subject.send(belongs_to_relationship.to_sym)).to eq model_object
      }

    end

  end

end
