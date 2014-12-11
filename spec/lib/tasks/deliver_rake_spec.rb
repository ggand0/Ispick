require 'spec_helper'

=begin
describe "deliver:all" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "calls deliver:user with valid times" do
    # Create two users
    FactoryGirl.create(:user)
    FactoryGirl.create(:user)

    Rake::Task['deliver:user'].stub(:invoke).and_return nil
    Rake::Task['deliver:user'].should_receive(:invoke).exactly(2).times

    subject.invoke
  end
  it "calls Deliver.deliver function indirectly" do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    Deliver.stub(:deliver).and_return nil
    #Rake::Task['deliver:user'].should_receive(:invoke).with(user1.id).exactly(1).times
    #Rake::Task['deliver:user'].should_receive(:invoke).with(user2.id).exactly(1).times
    Deliver.should_receive(:deliver).with(user1.id).exactly(1).times
    Deliver.should_receive(:deliver).with(user2.id).exactly(1).times

    subject.invoke
  end
end
=end
