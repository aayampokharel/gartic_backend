FROM golang:1.27.2-alpine3.24 as builder
WORKDIR /app
COPY go.mod go.sum .
RUN go mod download
COPY . . 
RUN go build -o ./gartic_backend .


FROM alpine:3.24.2 as prod
COPY --from=builder /app/gartic_backend ./gartic_prod
RUN chmod u+x ./gartic_prod
CMD  ./gartic_prod