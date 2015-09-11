NoCms::Blocks.configure do |config|

  config.templates[:one_column] = {
    blocks: [],
    zones: {
      header: {
        blocks: ["sample","sample2"]
      },
      body: {
        blocks: []
      },
    }
  }
end
