NoCms::Blocks.configure do |config|
  config.templates['three_column'] = {
    blocks: [:default],
    zones: {
      header: {
        blocks: [:header, :'title-3_columns', :'logo-caption']
      },
      body: {
        blocks: [:body, :nestable_container]
      },
      footer: {
      }
    }
  }
end
