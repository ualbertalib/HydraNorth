FactoryGirl.define do
  factory :collection do
    transient do
      user {FactoryGirl.create(:user)}
    end
    sequence(:title) {|n| "Title #{n}"}
    before(:create) { |work, evaluator| work.apply_depositor_metadata(evaluator.user.user_key) }
  end
end
