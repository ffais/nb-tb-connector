FROM maven:3.3-jdk-8 as mvn
COPY . /tmp
WORKDIR /tmp
RUN mvn install

FROM store/oracle/serverjre:8
ARG VER=0.1
ENV FOLDER=/tmp/target
ENV APP=nb-tb-connector-${VER}.jar
COPY --from=mvn ${FOLDER}/${APP} /tmp/target/
WORKDIR /tmp/target/
CMD [ "sh", "-c", "java -Xms32m -Xmx64m -jar ${APP}" ]
