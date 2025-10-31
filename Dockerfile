# Temel imaj olarak, bir Java Web Sunucusu (Tomcat) ve Java 17 kullanan bir imaj seçelim.
# Bu imaj, uygulamanın çalışması için gerekli Java ve sunucu ortamını sağlar.
FROM tomcat:10.0.27-jdk17-temurin-focal

# Uygulamanın .war dosyasını derleyip bu Dockerfile ile aynı dizine koyduğunuzu varsayalım.
# Projeyi derlemek için: ./mvnw package
# Derleme sonrası oluşan WAR dosyası genellikle 'target/spring-petclinic.war' yolundadır.
ARG WAR_FILE=target/spring-petclinic.war

# Derlenmiş WAR dosyasını Tomcat'in 'webapps' dizinine 'ROOT.war' adıyla kopyala.
# 'ROOT.war' olarak adlandırmak, uygulamaya doğrudan '/' yolundan erişilmesini sağlar (yani http://localhost:8080/).
COPY ${WAR_FILE} /usr/local/tomcat/webapps/ROOT.war

# Tomcat varsayılan olarak 8080 portunu kullanır.
EXPOSE 8080

# Tomcat'in başlangıç komutu (Temel imajda zaten tanımlı olabilir, bu sadece netlik için).
# CMD ["catalina.sh", "run"]
