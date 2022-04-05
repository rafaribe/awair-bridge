FROM gradle:jdk17 as build
WORKDIR /workspace/app
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY src src

RUN gradle build -x test
WORKDIR /extracted
RUN VERSION=`properties --no-daemon --console=plain -q | grep "^version:" | awk '{printf $2}'`
RUN jar -xf /workspace/app/build/libs/awair-bridge-$VERSION.jar

FROM eclipse-temurin:17-jre-focal
RUN mkdir /app
WORKDIR /app
COPY --from=build /extracted/BOOT-INF/lib /app/lib
COPY --from=build /extracted/META-INF /app/META-INF
COPY --from=build /extracted/BOOT-INF/classes /app

ENTRYPOINT ["java","-cp","app:app/lib/*","com.pw.awairbridge.AwairBridgeApplication"]