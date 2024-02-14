package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/aymerick/raymond"
)

// TemplateData struct to parse the incoming JSON payload
type TemplateData struct {
	Variables map[string]interface{} `json:"variables"`
}

// The Handlebars template is stored in memory
const templateString = `Hello, {{name}}! Your role is: {{role}}.`

// Global variable to store the parsed template
var parsedTemplate *raymond.Template

func main() {
	var err error
	// Parse the template and store it globally
	parsedTemplate, err = raymond.Parse(templateString)
	if err != nil {
		log.Fatalf("Failed to parse template: %v", err)
	}

	http.HandleFunc("/render", renderTemplateHandler)

	fmt.Println("Server is listening on :8082")
	log.Fatal(http.ListenAndServe(":8082", nil))
}

func renderTemplateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var tmplData TemplateData
	if err := json.NewDecoder(r.Body).Decode(&tmplData); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := parsedTemplate.Exec(tmplData.Variables)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(result))
}

