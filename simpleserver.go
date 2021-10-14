/*
Serve is a very simple static file server in go
Usage:
	-p="8888": port to serve on
	-d=".":    the directory of static files to host
Navigating to http://localhost:8888 will display the index.html or directory
listing file.
*/
package main

import (
	"flag"
	"log"
	"net/http"
)

func main() {
	// port := flag.String("p", "8888", "port to serve on")
	// directory := flag.String("d", ".", "the directory of static file to host")
	port := "8888"
	directory := "."
	flag.Parse()

	http.Handle("/", http.FileServer(http.Dir(directory)))

	log.Printf("Serving %s on HTTP port: %s\n", directory, port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
