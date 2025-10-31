FROM maven:3.9.9-eclipse-temurin-17

WORKDIR /app
COPY . .

# WAR dosyasını build et
RUN mvn clean package -DskipTests

# 8080 portunu aç
EXPOSE 8080

# Jetty ile uygulamayı ayağa kaldır
CMD ["mvn", "jetty:run-war"]
