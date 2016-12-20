FactoryGirl.define do
  factory :catering do
    shipping_id { (create :shipping, :unassociated).id }
    combo_id { (create :combo).id }
  end
end
