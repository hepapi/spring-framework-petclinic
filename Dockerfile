# ---- Build Stage ----
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# ---- Runtime Stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Jetty runner jar ekle
RUN mkdir -p /opt/jetty && \
    curl -L -o /opt/jetty/jetty-runner.jar \
    https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.53.v20231009/jetty-runner-9.4.53.v20231009.jar

# Build aşamasından WAR dosyasını al
COPY --from=build /app/target/*.war /app/app.war

EXPOSE 8080
CMD ["java", "-jar", "/opt/jetty/jetty-runner.jar", "--port", "8080", "/app/app.war"]
