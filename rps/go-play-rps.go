package main

import "fmt"
import "math/rand"
import "time"
import "bufio"
import "os"

func main() {
    for {
      bio := bufio.NewReader(os.Stdin)
      bio.ReadLine()

      rand.Seed( time.Now().UTC().UnixNano())
      i := rand.Intn(3)

      switch i {
        case 0: fmt.Println("rock");
        case 1: fmt.Println("paper");
        case 2: fmt.Println("scissors");
      }
    }
}
