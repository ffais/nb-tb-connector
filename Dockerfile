FROM maven:3.3-jdk-8
COPY . /tmp
WORKDIR /tmp
RUN mvn install

FROM store/oracle/serverjre:8
COPY --from=0 /tmp/target/nb-tb-connector-0.1.jar /tmp/target/
WORKDIR /tmp/target/
CMD ["java", "-Xms32m", "-Xmx64m", "-jar", "nb-tb-connector-0.1.jar"]

