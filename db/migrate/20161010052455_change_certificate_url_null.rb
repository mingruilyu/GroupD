class ChangeCertificateUrlNull < ActiveRecord::Migration
  def change
    change_column_null :restaurants, :certificate_url, true
  end
end
