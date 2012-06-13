# ------------------------------------------------------
# Defined the migrations
# ------------------------------------------------------
ActiveRecord::Schema.define(:version => 0) do

  create_table :code_sample_class, :force => true do |t|
    t.string :gender_code
    t.string :country_iso
  end


end
