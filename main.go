package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize a Gin router with default middleware
	r := gin.Default()

	// Define a simple GET route
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	// Run the server on port 8080
	r.Run()
}
