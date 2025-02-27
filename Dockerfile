FROM directus/directus:latest

COPY package.json .
COPY schema.sql /schema.sql

ENV PORT=8055
ENV PUBLIC_URL="https://railway-url.up.railway.app"
ENV DB_CLIENT="railway"
ENV ADMIN_EMAIL="calinmadalina30@gmail.com"
ENV ADMIN_PASSWORD="vCAihpGVGtSFrasyogkfaUMdThrJNxIa"
ENV KEY="random-key-string"
ENV SECRET="random-secret-string"

# If you want to pre-load your schema
# RUN apt-get update && apt-get install -y postgresql-client
# RUN PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -f /schema.sql

CMD npx directus bootstrap && npx directus start