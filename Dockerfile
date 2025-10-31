# Build stage
FROM maven:3.8.6-openjdk-18 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage with Tomcat 10
FROM tomcat:10-jdk17-openjdk-slim
WORKDIR /usr/local/tomcat/webapps
COPY --from=build /app/target/*.war ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
