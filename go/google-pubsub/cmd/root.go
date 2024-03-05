/*
Copyright © 2022-2023 Nils Knieling <https://github.com/Cyclenerd>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"cloud.google.com/go/pubsub"
	"context"
	"github.com/pterm/pterm"
	"github.com/spf13/cobra"
	"os"
)

var version string = "v?.?.?"

var inputProject string
var inputTopic string
var inputMessage string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:     "pubsub-publish",
	Version: version,
	Short:   "Publish a message to the specified Google Cloud Pub/Sub topic",
	Long: `Publish a message to the specified Google Cloud Pub/Sub topic.

Set the environment variable GOOGLE_APPLICATION_CREDENTIALS to
the path of the JSON file that contains your service account key.

Authentication:
export GOOGLE_APPLICATION_CREDENTIALS="PATH_TO_JSON_KEY"

More help: <https://github.com/Cyclenerd/google-cloud-pubsub-publish>`,
	Run: func(cmd *cobra.Command, args []string) {
		ctx := context.Background()
		// Create a client
		client, err := pubsub.NewClient(ctx, inputProject)
		if err != nil {
			pterm.Error.Println(err)
			os.Exit(8)
		}
		defer client.Close()
		t := client.Topic(inputTopic)
		result := t.Publish(ctx, &pubsub.Message{
			Data: []byte(inputMessage),
		})
		// Block until the result is returned and a server-generated
		// ID is returned for the published message.
		id, err := result.Get(ctx)
		if err != nil {
			pterm.Error.Println(err)
			os.Exit(1)
		}
		pterm.Success.Printf("Published message with ID: %v\n", id)
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(9)
	}
}

func init() {
	// Disable the default completion command:
	rootCmd.CompletionOptions.DisableDefaultCmd = true
	// Here you will define your flags and configuration settings.
	rootCmd.PersistentFlags().StringVarP(&inputProject, "project", "p", "", "Google Cloud project ID (required)")
	_ = rootCmd.MarkPersistentFlagRequired("project")
	rootCmd.PersistentFlags().StringVarP(&inputTopic, "topic", "t", "", "Topic ID or fully qualified identifier for the topic (required)")
	_ = rootCmd.MarkPersistentFlagRequired("topic")
	rootCmd.PersistentFlags().StringVarP(&inputMessage, "message", "m", "", "The body of the message to publish to the given topic name (required)")
	_ = rootCmd.MarkPersistentFlagRequired("message")
}
