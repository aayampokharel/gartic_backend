FROM ghcr.io/cirruslabs/flutter:stable as build
WORKDIR /gartic_frontend
COPY ./gartic_frontend/pubspec.* ./
RUN flutter pub get
COPY gartic_frontend/ .
RUN flutter build web --release


FROM nginx:alpine
COPY --from=build /gartic_frontend/build/web /usr/share/nginx/html
EXPOSE 80