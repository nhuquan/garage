# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Install dart_frog_cli
RUN dart pub global activate dart_frog_cli
ENV PATH="${PATH}:${HOME}/.pub-cache/bin"

# Build the production server
RUN dart_frog build

# Final stage
FROM dart:stable

WORKDIR /app

# Copy the build output from the build stage
COPY --from=build /app/build /app

# Install dependencies for the production build
RUN dart pub get 

# Set environment variables for the runtime
ENV DB_HOST=db
ENV DB_PORT=5432
ENV DB_NAME=garage_db
ENV DB_USER=garage_user
ENV DB_PASSWORD=garage_password

# Start the server
EXPOSE 8080
CMD ["dart", "bin/server.dart"]
