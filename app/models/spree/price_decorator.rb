Spree::Price.class_eval do
  def self.get_price_levels()
    return [
        {name: "$", min: 0, max: 10},
        {name: "$$", min: 11, max: 100},
        {name: "$$$", min: 101, max: 1000},
        {name: "$$$$", min: 1001, max: 10000},
        {name: "$$$$$", min: 10001, max: 100000}
    ]
  end
end