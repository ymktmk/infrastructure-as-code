package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecs"
)

type Response struct {
	Message string `json:"message"`
}

func Handler() (Response, error) {

	svc := ecs.New(session.New())

	input := &ecs.StopTaskInput{
		Cluster: aws.String("online-code"),
		Task: aws.String(""),
	}

	// input := &ecs.UpdateServiceInput{
	// 	Cluster: aws.String("online-code"),
	// 	Service: aws.String("online-code"),
	// 	DesiredCount: aws.Int64(1),
	// }

	result, err := svc.StopTask(input)

	if err != nil {
		fmt.Println(err)
	}

	fmt.Println(result)

	return Response{
		Message: "ECS Task Stop successfully!",
	}, nil
}

func main() {
	// Handler()
	lambda.Start(Handler)
}
