package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ses"
)

type Message struct {
	Default  string  `json:"default"`
	Email    string  `json:"email"`
}

const (
	charSet       = "UTF-8"
	sourceAddress = "info@stg.encer.jp"
)

func send(ctx context.Context, snsEvent events.SNSEvent) error {

	var message Message
	err := json.Unmarshal([]byte(snsEvent.Records[0].SNS.Message), &message)
	if err != nil {
		log.Fatalln(err)
		return err
	}

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"),
	})

	if err != nil {
		log.Fatalln(err)
		return err
	}

	svc := ses.New(sess)

	input := &ses.SendEmailInput{
		Destination: &ses.Destination{
			ToAddresses: []*string{
				aws.String(message.Email),
			},
		},
		Message: &ses.Message{
			Body: &ses.Body{
				Html: &ses.Content{
					Charset: aws.String(charSet),
					Data:    aws.String(message.Default),
				},
			},
			Subject: &ses.Content{
				Charset: aws.String(charSet),
				Data:    aws.String("○○からメッセージが届きました。"),
			},
		},
		Source: aws.String(sourceAddress),
	}

	_, err = svc.SendEmail(input)

	return err
}

func main() {
	lambda.Start(send)
}
