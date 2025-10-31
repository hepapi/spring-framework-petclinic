# Multi-stage build için Maven ve JDK 17 kullanıyoruz
FROM maven:3.9-eclipse-temurin-17 AS build

# Çalışma dizinini ayarla
WORKDIR /app

# pom.xml ve Maven wrapper dosyalarını kopyala
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
COPY mvnw.cmd .

# Bağımlılıkları önce indir (cache optimizasyonu için)
RUN mvn dependency:go-offline -B

# Kaynak kodları kopyala
COPY src ./src

# Uygulamayı derle ve WAR dosyası oluştur
RUN mvn clean package -DskipTests

# Runtime stage - Jetty ile çalıştırma
FROM jetty:11-jdk17-eclipse-temurin

# WAR dosyasını ROOT olarak kopyala (root context için)
COPY --from=build /app/target/*.war /var/lib/jetty/webapps/ROOT.war

# Jetty'nin 8080 portunu expose et
EXPOSE 8080

# Spring profile ayarla (JPA varsayılan)
ENV SPRING_PROFILES_ACTIVE=jpa

# Jetty'yi başlat
CMD ["java", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", "-jar", "/usr/local/jetty/start.jar"]
