package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net"
	"net/http"
	"os"
	"time"
)

// notification defines the data-structure sent by the agent
// the agent is identified by the Hostname/MAC address of the host
type notification struct {
	Host   string `json:"host,omitempty"`
	Mac    string `json:"mac,omitempty"`
	Tstamp string `json:"timestamp,omitempty"`
	Val    string `json:"value,omitempty"`
}

func (n notification) String() string {
	return fmt.Sprintf("Host: %s, Mac: %s, Val: %s, Tstamp: %s", n.Host, n.Mac, n.Val, n.Tstamp)
}

func main() {
	rand.Seed(time.Now().UnixNano())
	var (
		maxWaitSec int = 10
		minWaitSec int = 1
	)

	// the relevant values to configure the agent are supplied via Env-Vars.
	// if no specific Env-Vars are available sensible standards/defaults are used
	daprHost := getEnvOrStd("DAPR_HOST", "localhost")
	daprPort := getEnvOrStd("DAPR_HTTP_PORT", "3500")
	pubSubName := getEnvOrStd("PUBSUB_NAME", "pubsub")
	pubSubTopic := getEnvOrStd("PUBSUB_TOPIC", "notifications")
	daprHttpHost := fmt.Sprintf("http://%s:%s/v1.0/publish/%s/%s", daprHost, daprPort, pubSubName, pubSubTopic)

	fmt.Printf("use pubsub: %s\n", daprHttpHost)

	macs, err := getMacAddr()
	if err != nil {
		log.Fatal(err.Error())
		os.Exit(1)
	}

	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err.Error())
		os.Exit(1)
	}

	for {
		randWait := rand.Intn(maxWaitSec-minWaitSec) + minWaitSec

		// create the notification payload by using the MAC address, current timestamp and a random value
		notify := notification{
			Host:   hostname,
			Mac:    macs[0],
			Tstamp: time.Now().Format(time.RFC3339),
			Val:    randString(16),
		}

		// the payload is marahaled to JSON
		payload, err := json.Marshal(notify)
		if err != nil {
			log.Fatal(err.Error())
			os.Exit(1)
		}

		fmt.Printf("JSON: %s\n", string(payload))

		// Publish an event using Dapr pub/sub
		// NOTE: we do not have ANY additional dependency/framework - we are only using plain HTTP!
		client := http.Client{}
		req, err := http.NewRequest("POST", daprHttpHost, bytes.NewReader(payload))
		if err != nil {
			log.Fatal(err.Error())
			os.Exit(1)
		}
		req.Header.Set("Content-Type", "application/json; charset=UTF-8")
		fmt.Printf("will publish a new notification - '%s'\n", notify.String())
		res, err := client.Do(req)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("got result: %s\n", res.Status)

		time.Sleep(time.Duration(randWait) * time.Second)
	}

}

func getEnvOrStd(envKey, std string) string {
	val := os.Getenv(envKey)
	if val == "" {
		return std
	}
	return val
}

// stackoverflow - as usual!
func getMacAddr() ([]string, error) {
	ifas, err := net.Interfaces()
	if err != nil {
		return nil, err
	}
	var as []string
	for _, ifa := range ifas {
		a := ifa.HardwareAddr.String()
		if a != "" {
			as = append(as, a)
		}
	}
	return as, nil
}

var letterRunes = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func randString(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letterRunes[rand.Intn(len(letterRunes))]
	}
	return string(b)
}
