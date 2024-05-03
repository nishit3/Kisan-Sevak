#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

const char* ssid = "ssid";
const char* password = "pass";
const char* host = "ENDPOINT";
const int httpsPort = 443;
             

int FA_LED = 23;
int Ir_LED = 22;
int FL_LED = 32;
int CO2_LED = 33;

void setup() {
  Serial.begin(115200);  
  pinMode(FA_LED, OUTPUT);  
  pinMode(Ir_LED, OUTPUT);
  pinMode(FL_LED, OUTPUT);  
  pinMode(CO2_LED, OUTPUT);
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}
 
void loop() {
        
  WiFiClientSecure client;
  client.setInsecure();
  if (client.connect(host, httpsPort)) {
    client.print(String("GET /prod/get-home-module-notifs HTTP/1.1\r\n") +
                 "Host: " + host + "\r\n" +
                 "Connection: close\r\n\r\n");
    
    while (client.connected() || client.available()) {
      if (client.available()) {
        char c = client.read();
        if (c == '\r' || c == '\n') {
          // Check for the end of headers
          if (client.read() == '\n' && client.read() == '\r') {
            break;
          }
        }
      }
    }

    String jsonResponse = "";
    while (client.connected() || client.available()) {
      if (client.available()) {
        char c = client.read();
        jsonResponse += c;
      }
    }

    DynamicJsonDocument doc(10240);  
    deserializeJson(doc, jsonResponse);

    JsonArray alerts = doc["alerts"].as<JsonArray>();

    if (alerts.size() > 0) {
      // Iterate through each alert object
      for (JsonObject alert : alerts) {
        const char* uid = alert["UID"];
        if(alert["Type"] == "FA")
        {
          digitalWrite(FA_LED, HIGH);
          delay(3000);
          digitalWrite(FA_LED, LOW);
        }
        else if(alert["Type"] == "CO2")
        {
          digitalWrite(CO2_LED, HIGH);
          delay(3000);
          digitalWrite(CO2_LED, LOW);
        }
        else if(alert["Type"] == "FL")
        {
          digitalWrite(FL_LED, HIGH);
          delay(3000);
          digitalWrite(FL_LED, LOW);
        }
        else if(alert["Type"] == "Ir")
        {
          digitalWrite(Ir_LED, HIGH);
          delay(3000);
          digitalWrite(Ir_LED, LOW);
        }
        WiFiClientSecure client2;
        client2.setInsecure();
        String encodedUID = String(uid);
        encodedUID.replace(" ", "%20");
        encodedUID.replace("/", "%2F");
        encodedUID.replace(":", "%3A");
        if (client2.connect(host, httpsPort)) {
          String getRequest = "GET /prod/delete-home-module-notifs?UID="+encodedUID+ " HTTP/1.1\r\n";
          getRequest += "Host: " + String(host) + "\r\n";
          getRequest += "Connection: close\r\n\r\n";
          Serial.println("Sending request:");
          Serial.println(getRequest);
          client2.print(getRequest);
          client2.stop();
        }
        delay(1000);
      }
    } else {
      Serial.println("No alerts found.");
    }
    client.stop();
  } else {
    Serial.println("Connection failed");
  }
  delay(5000);
}
