FactoryGirl.define do
  factory :generic_file do
    transient do
      depositor "archivist1@example.com"
    end
    before(:create) do |gf, evaluator|
      gf.apply_depositor_metadata evaluator.depositor
    end
  end
end
