# Maven + JDK17 ile build aşaması
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .

# Maven ile build (testleri atlıyoruz)
RUN mvn clean package -DskipTests
RUN ls -la /app/target

# Çalışma imajı
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

CMD ["java", "-jar", "app.jar"]
