package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	Message string `json:"message"`
}

func Handler() (Response, error) {

	fmt.Println("this is log")

	return Response{
		Message: "Go Serverless v1.0! Your function executed successfully!",
	}, nil
}

func main() {
	// Handler()
	lambda.Start(Handler)
}
