FROM alpine/git:2.47.2 AS code
WORKDIR /code
RUN git clone https://github.com/chubbyhippo/spring-boot-web-hello-maven-java.git app

FROM bellsoft/liberica-openjre-alpine:21-cds AS builder
COPY --from=code /code/app /builder
WORKDIR /builder
RUN ./mvnw package
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

FROM bellsoft/liberica-openjre-alpine:21-cds
WORKDIR /application
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./
ENTRYPOINT ["java", "-jar", "application.jar"]
