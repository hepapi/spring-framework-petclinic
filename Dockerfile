FROM jetty:11-jdk17-eclipse-temurin

WORKDIR /app

# Jenkins pipeline'da üretilmiş WAR dosyasını buraya kopyalayacağız
COPY target/*.war /var/lib/jetty/webapps/ROOT.war

EXPOSE 8080

ENV JAVA_OPTIONS="-Dspring.profiles.active=jpa"

CMD ["java", "-Dspring.profiles.active=jpa", "-jar", "/usr/local/jetty/start.jar"]

