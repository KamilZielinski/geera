class Git
  def self.create_and_checkout(name : String)
    `git checkout -b #{name}`
  end

  def self.checkout(name : String)
    `git checkout #{name}`
  end

  def self.fetch
    `git fetch`
  end

  def self.find_branch_starting_with(name : String)
    `git branch --all | grep -i #{name}`.split("\n").first.gsub("*", "").strip
  end
end
