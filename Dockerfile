# -------- BUILD STAGE --------
FROM maven:3.8.6-openjdk-18 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# -------- RUNTIME STAGE (TOMCAT 9) --------
FROM tomcat:9.0.82-jdk17-temurin
WORKDIR /usr/local/tomcat/webapps

# Remove default ROOT app
RUN rm -rf ROOT

# Copy our WAR as ROOT.war
COPY --from=build /app/target/*.war ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
