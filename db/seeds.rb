user = User.create(:email => 'dbolson@gmail.com', :password => 'm3tal!', :password_confirmation => 'm3tal!')
user2 = User.create(:email => 'invisibleoranges@gmail.com', :password => 'm3tal!', :password_confirmation => 'm3tal!')
user.adminify!
user2.adminify!
