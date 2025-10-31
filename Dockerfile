FROM maven:3.8.6-openjdk-18 AS build
WORKDIR /app
COPY application/ .
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/spring-petclinic-*.jar /app/spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "/app/spring-petclinic.jar"]
EXPOSE 8080
