FROM directus/directus:latest

COPY package.json .
COPY schema.sql /schema.sql

ENV PORT=8055
ENV PUBLIC_URL="https://railway-url.up.railway.app"
ENV DB_CLIENT="railway"
ENV ADMIN_EMAIL="calinmadalina30@gmail.com"
ENV ADMIN_PASSWORD="MedicalAppUpb2025"
ENV KEY="Gz^Nu+bPtA(%V/.s<E$7?D93qR;4QecS"
ENV SECRET="j6x+ydR#>uHD;fc5hG{~M)W*82%J!Fb/"

# If you want to pre-load your schema
# RUN apt-get update && apt-get install -y postgresql-client
# RUN PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -f /schema.sql

CMD npx directus bootstrap && npx directus start