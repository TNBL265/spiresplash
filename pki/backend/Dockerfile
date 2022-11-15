FROM nginx:latest

# Add hostname
RUN echo "${BACKEND_SVC} backend" >> /etc/hosts

# Static content for symbank
COPY ./backend/json/balances /usr/share/nginx/html/balances
COPY ./backend/json/profiles /usr/share/nginx/html/profiles
COPY ./backend/json/transactions /usr/share/nginx/html/transactions

COPY ./backend/json/balances /usr/share/nginx.html/balances
COPY ./backend/json/profiles /usr/share/nginx.html/profiles
COPY ./backend/json/transactions /usr/share/nginx.html/transactions

COPY ./backend/nginx.conf /etc/nginx/conf.d/nginx.conf
