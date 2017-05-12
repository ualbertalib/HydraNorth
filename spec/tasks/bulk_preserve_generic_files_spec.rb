require 'spec_helper'

describe "hydranorth:bulk_preserve_generic_files", type: :task do
  before(:all) do
    load_rake_environment('tasks/bulk_preserve_generic_files')
  end

  let!(:file) do
    FactoryGirl.build(:generic_file, title: ["Foo"],) do |work|
      work.apply_depositor_metadata('dittest@ualberta.ca')
      work.save
    end
  end

  before(:each) do
    # clear out the test preservation queue for consistent results
    $redis.del Hydranorth::PreservationQueue::QUEUE_NAME
  end

  after(:each) do
    Timecop.return
    cleanup_jetty
  end

  it "puts generic files noids in the queue with the right score" do
    now = Time.now
    Timecop.freeze(now)

    run_rake_task('hydranorth:bulk_preserve_generic_files')

    noid, score = $redis.zrange(Hydranorth::PreservationQueue::QUEUE_NAME, 0, -1, with_scores: true)[0]

    expect(noid).to eq file.id
    expect(score).to be_within(0.5).of now.to_f

  end
end
