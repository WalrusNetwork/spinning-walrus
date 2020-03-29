package main

import "fmt"
import "net"
import "strings"
import "time"

const NUM_FIELDS int = 6
const DEFAULT_TIMEOUT int = 5 // default TCP timeout in seconds
var Address string
var Port string
var Online bool               // online or offline?
var Version string            // server version
var Motd string               // message of the day
var Current_players string    // current number of players online
var Max_players string        // maximum player capacity
var Latency time.Duration     // ping time to server in milliseconds

func checker(given_address string, given_port string, optional_timeout ...int) {
  timeout := DEFAULT_TIMEOUT
  if len(optional_timeout) > 0 {
    timeout = optional_timeout[0]
  }
  Address = given_address
  Port = given_port
  /* Latency may report a misleading value of >1s due to name resolution delay when using net.Dial().
     A workaround for this issue is to use an IP address instead of a hostname or FQDN. */
  start_time := time.Now()
  conn, err := net.DialTimeout("tcp", Address + ":" + Port, time.Duration(timeout) * time.Second)
  Latency = time.Since(start_time)
  Latency = Latency.Round(time.Millisecond)
  if err != nil {
    Online = false
    return
  }

  _, err = conn.Write([]byte("\xFE\x01"))
  if err != nil {
    Online = false
    return
  }

  raw_data := make([]byte, 512)
  _, err = conn.Read(raw_data)
  if err != nil {
    Online = false
    return
  }
  conn.Close()

  if raw_data == nil || len(raw_data) == 0 {
    Online = false
    return
  }

  data := strings.Split(string(raw_data[:]), "\x00\x00\x00")
  if data != nil && len(data) >= NUM_FIELDS {
    Online = true
    Version = data[2]
    Motd = data[3]
    Current_players = data[4]
    Max_players = data[5]
  } else {
    Online = false
  }
}

func main() {
  checker("127.0.0.1", "25565")
  if Online {
    fmt.Printf("%s", Current_players)
  } else {
    fmt.Println("offline")
  }
}