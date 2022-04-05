FROM gradle:jdk17 as build
WORKDIR /workspace/app
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY src src

RUN gradle build -x test -DspringAot=false
WORKDIR /extracted
RUN JAR_VER=${gradle properties -q | grep "version:" | awk '{print $2}'} && jar -xf /workspace/app/build/libs/awair-bridge-$JAR_VER.jar

FROM eclipse-temurin:17-jre-focal
RUN mkdir /app
WORKDIR /app
COPY --from=build /extracted/BOOT-INF/lib /app/lib
COPY --from=build /extracted/META-INF /app/META-INF
COPY --from=build /extracted/BOOT-INF/classes /app

ENTRYPOINT ["java","-cp","app:app/lib/*","com.pw.awairbridge.AwairBridgeApplication"]