# Build stage
FROM maven:3.8.6-openjdk-18 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar /app/spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "/app/spring-petclinic.jar"]
EXPOSE 8080
