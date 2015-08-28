shared_examples_for "model with has many through belongs to relationship" do |
  model_name,
  through_model_factory,
  related_model_factory,
  has_many_relationship,
  belongs_to_relationship,
  through_relationship|

  context "when creating various #{through_relationship}" do

    let!(:model_object) { create model_name, has_many_relationship => [ through_object_1, through_object_2 ]  }
    let!(:through_object_1)  { create through_model_factory, belongs_to_relationship => related_object_1 }
    let!(:related_object_1)  { create related_model_factory }
    let!(:through_object_2)  { create through_model_factory, belongs_to_relationship => related_object_2 }
    let!(:related_object_2)  { create related_model_factory }

    subject { model_object }

    it("should relate to all of its #{through_relationship}") { expect(subject.send(through_relationship.to_sym)).to match_array [related_object_1, related_object_2] }

  end

end
