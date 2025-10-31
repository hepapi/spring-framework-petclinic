# Build stage
FROM maven:3.8.6-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage (Jetty)
FROM maven:3.8.6-openjdk-17
WORKDIR /app
COPY . .
EXPOSE 8080
CMD ["mvn", "jetty:run-war"]
