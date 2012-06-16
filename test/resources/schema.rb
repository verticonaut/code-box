# ------------------------------------------------------
# Defined the migrations
# ------------------------------------------------------
ActiveRecord::Schema.define(:version => 0) do

  create_table :codes_sample_class, :force => true do |t|
    t.string :gender_code
    t.string :country_iso

    t.string :civil_status_code
    t.string :ager_type_code

    t.string :country_2_code
  end

  create_table :codes_country, :force => true do |t|
    t.string :code
    t.string :name
  end

  create_table :codes_ar_code, :force => true do |t|
    t.string  :code
    t.string  :name
    t.integer :position
  end

end
