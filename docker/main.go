package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		interfaces, err := net.Interfaces()
		if err != nil {
			fmt.Println(err)
			return
		}
		for _, inter := range interfaces {
			addrs, err := inter.Addrs()
			if err != nil {
				fmt.Println(err)
				return
			}
			for _, a := range addrs {
				if ipnet, ok := a.(*net.IPNet); ok {
					if ipnet.IP.To4() != nil {
						fmt.Fprintf(w, ipnet.IP.String() + "\n")
					}
				}
			}
		}
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}
