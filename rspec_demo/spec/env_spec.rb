# Various tests to check if the variables we expect, are in the System ENV
# provided by Elir
context "ENV" do
  it "can find variables in the system environment" do
    sleep(Random.rand(5))
    expect(ENV['device']).not_to be_nil
    expect("#{ENV['language']}").to eql("en")
    expect(ENV['server']).not_to be_nil    
  end
end
