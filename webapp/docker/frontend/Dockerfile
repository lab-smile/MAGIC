# Build stage
FROM node:14 as build
WORKDIR /app
COPY webapp/package*.json ./
RUN npm install
COPY webapp/ ./
RUN npm run build

# Production stage
FROM node:14 as production
RUN npm install -g serve
WORKDIR /app
COPY --from=build /app/ .
CMD ["serve", "-s", "build"]