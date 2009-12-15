class PepperTest < Test::Unit::TestCase
  context "logging in" do
    should "open connection when login called" do
      mock(Pepper).connect { StringIO.new }
      Pepper.login
    end
  end
end