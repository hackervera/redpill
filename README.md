Firstly, copy `config-sample.yaml` to `config.yaml` and replace values with your own. Then run `bundle install`

You need to update your homeserver data to include application password. From your server `sqlite3 homeserver.db` then `insert into application_services(token) values("your-password");`

You also need to run `ruby intialize_app.rb` once to initialize app and then run `ruby webserver.rb` to start server.


Once everything is running you should be able to join `#irc/your-channel:example.com` inside Matrix and the bot will automatically join `your-channel:example.com` on the configured irc server when you send your first message.
