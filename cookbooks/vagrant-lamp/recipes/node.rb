# Install npm modules
%w{ gulp grunt bower yo less csslint }.each do |a_package|
  nodejs_npm a_package do
      options ["--global"]
  end
end
