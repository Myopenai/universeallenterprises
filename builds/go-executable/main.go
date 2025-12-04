package main

import (
	"embed"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"os"
	"time"
)

// version/buildTime are injected via -ldflags (see build-all.ps1)
var (
	version   = "dev"
	buildTime = ""
)

//go:embed web/*
var webFS embed.FS

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "9090"
	}

	sub, err := fs.Sub(webFS, "web")
	if err != nil {
		log.Fatalf("failed to mount embedded web FS: %v", err)
	}
	static := http.FileServer(http.FS(sub))

	mux := http.NewServeMux()

	// status API
	mux.HandleFunc("/api/status", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		bt := buildTime
		if bt == "" {
			bt = time.Now().UTC().Format(time.RFC3339)
		}
		fmt.Fprintf(w, `{"ok":true,"version":"%s","buildTime":"%s","port":"%s"}`, version, bt, port)
	})

	// root: serve embedded index.html
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		r.URL.Path = "/index.html"
		static.ServeHTTP(w, r)
	})

	addr := ":" + port
	log.Printf("CognitiveFabric (embedded) listening at http://127.0.0.1%s  version=%s", addr, version)
	log.Fatal(http.ListenAndServe(addr, mux))
}

package main

import (
	"embed"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"os"
	"time"
)

// version/buildTime are injected via -ldflags (see build-all.ps1)
var (
	version   = "dev"
	buildTime = ""
)

//go:embed web/*
var webFS embed.FS

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "9090"
	}

	sub, err := fs.Sub(webFS, "web")
	if err != nil {
		log.Fatalf("failed to mount embedded web FS: %v", err)
	}
	static := http.FileServer(http.FS(sub))

	mux := http.NewServeMux()

	// status API
	mux.HandleFunc("/api/status", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		bt := buildTime
		if bt == "" {
			bt = time.Now().UTC().Format(time.RFC3339)
		}
		fmt.Fprintf(w, `{"ok":true,"version":"%s","buildTime":"%s","port":"%s"}`, version, bt, port)
	})

	// root: serve embedded index.html
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Normalize: only serve the embedded app; ignore unknown paths
		r.URL.Path = "/index.html"
		static.ServeHTTP(w, r)
	})

	addr := ":" + port
	log.Printf("CognitiveFabric (embedded) listening at http://127.0.0.1%s  version=%s", addr, version)
	log.Fatal(http.ListenAndServe(addr, mux))
}


