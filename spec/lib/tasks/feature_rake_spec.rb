describe "feature:face_target" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid a method" do
    suject.invoke.should_raise
  end
end