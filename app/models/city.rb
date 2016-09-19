class City < ActiveRecord::Base
	has_many :users

  def as_json(options={})
    super(except: [:created, :updated_at])
  end
end
