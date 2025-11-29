# Stage 1: Build WAR using Maven-deneme-new-image-second
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
COPY mvnw.cmd .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run app on Jetty
FROM jetty:11-jdk17-eclipse-temurin
COPY --from=build /app/target/*.war /var/lib/jetty/webapps/ROOT.war

EXPOSE 8080
ENV JAVA_OPTIONS="-Dspring.profiles.active=jpa"

CMD ["java", "-Dspring.profiles.active=jpa", "-jar", "/usr/local/jetty/start.jar"]
