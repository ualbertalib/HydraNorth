FactoryGirl.define do
  factory :collection do
    transient do
      user {FactoryGirl.find_or_create(:user)}
    end
    sequence(:title) {|n| "Title #{n}"}
    before(:create) { |work, evaluator| work.apply_depositor_metadata(evaluator.user.user_key) }
  end
end
