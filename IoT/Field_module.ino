#include <DHT.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>

#define DHTPIN 3
#define DHTTYPE DHT11
const int moisture_pin = 32;
DHT dht(DHTPIN, DHTTYPE);

const char* ssid = "SSID";
const char* password = "pass";
const char* host = "ENDPOINT";
const int httpsPort = 443;

void setup() {
  Serial.begin(115200);
  dht.begin();
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

void loop() {
  String fmUID = "fm1";
  float humid = dht.readHumidity();
  float temp = dht.readTemperature();
  float Nitrogen = 12.00;
  float Potassium = 15.00;
  float Phosphorous = 0.00;
  float pH = 7.00;

  float moisture_analog = analogRead(moisture_pin);
  float moisture = ( 100 - ( (moisture_analog/4095.00) * 100 ) );

  WiFiClientSecure client2;
  client2.setInsecure();
  
  if (client2.connect(host, httpsPort)) {
    String getRequest = "GET /prod/update-soil-data?Temperature="+String(temp)+"&Humidity="+String(humid)+"&Moisture="+String(moisture)+"&Nitrogen="+String(Nitrogen)+"&Potassium="+String(Potassium)+"&Phosphorous="+String(Phosphorous)+"&fmUID="+fmUID+"&pH="+String(pH)+ " HTTP/1.1\r\n";
    getRequest += "Host: " + String(host) + "\r\n";
    getRequest += "Connection: close\r\n\r\n";
    Serial.println("Sending request:");
    Serial.println(getRequest);
    client2.print(getRequest);
    client2.stop();

  }
  delay(5000);
}
