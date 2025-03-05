FROM alpine/git:2.47.2 AS code
WORKDIR /code
RUN git clone https://github.com/chubbyhippo/spring-boot-web-hello-maven-java.git ./

FROM bellsoft/liberica-openjdk-alpine:21-cds AS builder
COPY --from=code /code /builder
WORKDIR /builder
RUN chmod +x mvnw
RUN ./mvnw package
RUN cp /builder/target/*.jar application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

FROM bellsoft/liberica-openjre-alpine:21-cds
WORKDIR /application
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./
ENTRYPOINT ["java", "-jar", "application.jar"]
