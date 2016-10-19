FROM convox/jekyll

# copy only the files needed for bundle install
COPY Gemfile      /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY _config/nginx.conf /etc/nginx/server.d/convox.conf

COPY . /app
